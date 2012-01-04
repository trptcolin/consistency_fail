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
      association = double("association", :macro => :has_one)
      model.stub!(:reflect_on_all_associations).and_return([association])

      subject.instances(model).should == [association]
    end

    it "finds other associations, but not has_one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :has_many)
      model.stub!(:reflect_on_all_associations).and_return([validation])

      subject.instances(model).should == []
    end
  end

  describe "finding missing indexes" do
    before do
      @association = double("association", :macro => :has_one)
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :reflect_on_all_associations => [@association])
    end

    it "finds one" do
      @association.stub!(:table_name => :addresses, :primary_key_name => "user_id")
      @model.stub_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("addresses", ["user_id"])]
    end

    it "finds none when they're already in place" do
      @association.stub!(:table_name => :addresses, :primary_key_name => "user_id")
      index = ConsistencyFail::Index.new("addresses", ["user_id"])

      fake_connection = double("connection")
      @model.stub_chain(:connection).and_return(fake_connection)

      ConsistencyFail::Introspectors::TableData.stub_chain(:new, :unique_indexes_by_table).
        with(fake_connection, "addresses").
        and_return([index])

      subject.missing_indexes(@model).should == []
    end

  end
end


