require 'spec_helper'
require 'consistency_fail/introspectors/validates_uniqueness_of'

describe ConsistencyFail::Introspectors::ValidatesUniquenessOf do
  def introspector(model)
    ConsistencyFail::Introspectors::ValidatesUniquenessOf.new(model)
  end

  describe "instances of validates_uniqueness_of" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub!(:reflect_on_all_validations).and_return([])

      subject.instances(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_uniqueness_of)
      model.stub!(:reflect_on_all_validations).and_return([validation])

      subject.instances(model).should == [validation]
    end

    it "finds other validations, but not uniqueness" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_format_of)
      model.stub!(:reflect_on_all_validations).and_return([validation])

      subject.instances(model).should == []
    end
  end

  describe "finding missing indexes" do
    before do
      @validation = double("validation", :macro => :validates_uniqueness_of)
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :reflect_on_all_validations => [@validation])
    end

    it "finds one" do
      @validation.stub!(:name => :email, :options => {})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["email"])]
    end

    it "finds one where the validation has scoped columns" do
      @validation.stub!(:name => :city, :options => {:scope => [:email, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["city", "email", "state"])]
    end

    it "sorts the scoped columns" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["city", "email", "state"])]
    end

    it "finds none when they're already in place" do
      @validation.stub!(:name => :email, :options => {})
      index = fake_index_on(["email"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes(@model).should == []
    end

    it "finds none when indexes are there but in a different order" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      index = fake_index_on(["state", "email", "city"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes(@model).should == []
    end
  end
end
