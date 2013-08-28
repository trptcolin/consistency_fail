require 'spec_helper'
require 'consistency_fail/introspectors/table_data'
require 'consistency_fail/introspectors/has_one'

describe ConsistencyFail::Introspectors::HasOne do
  def introspector(model)
    ConsistencyFail::Introspectors::HasOne.new(model)
  end

  describe "instances of has_one" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub(:reflect_on_all_associations).and_return([])

      subject.instances(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {})
      model.stub!(:reflect_on_all_associations).and_return([association])

      subject.instances(model).should == [association]
    end

    it "finds other associations, but not has_one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :has_many)
      model.stub!(:reflect_on_all_associations).and_return([validation])

      subject.instances(model).should == []
    end

    it "finds one, but it's a polymorphic association" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {:as => "addressable"})
      model.stub!(:reflect_on_all_associations).and_return([association])

      subject.instances(model).should == []
    end

    it "finds one, but it's a :through association" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {:through => :amodel})
      model.stub!(:reflect_on_all_associations).and_return([association])

      subject.instances(model).should == []
    end
  end

  describe "finding missing indexes" do
    before do
      @association = double("association", :macro => :has_one, :options => {})
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :class_name => "User",
                                     :reflect_on_all_associations => [@association])
      @address_class = double("Address Class")
      @address_string = "Address"
      @address_string.stub(:constantize).and_return(@address_class)
    end

    it "finds one" do
      @association.stub!(:table_name => :addresses, :class_name => @address_string, :foreign_key => "user_id")
      @address_class.stub_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new(fake_ar_model("Address"), "addresses", ["user_id"])]
    end

    it "finds one in Rails 3.0.x (where foreign_key is not defined)" do
      @association.stub!(:table_name => :addresses, :class_name => @address_string, :primary_key_name => "user_id")
      @address_class.stub_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new(fake_ar_model("Address"), "addresses", ["user_id"])]
    end

    it "finds none when they're already in place" do
      @association.stub!(:table_name => :addresses, :class_name => @address_string, :foreign_key => "user_id")
      index = ConsistencyFail::Index.new(double('model'), "addresses", ["user_id"])

      fake_connection = double("connection")
      @address_class.stub_chain(:connection).and_return(fake_connection)

      ConsistencyFail::Introspectors::TableData.stub_chain(:new, :unique_indexes_by_table).
        with(@address_class, fake_connection, "addresses").
        and_return([index])

      subject.missing_indexes(@model).should == []
    end

  end
end


