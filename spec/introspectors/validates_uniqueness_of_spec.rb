require 'spec_helper'
require 'consistency_fail/introspectors/validates_uniqueness_of'

describe ConsistencyFail::Introspectors::ValidatesUniquenessOf do
  def introspector(model)
    ConsistencyFail::Introspectors::ValidatesUniquenessOf.new(model)
  end

  describe "instances of validates_uniqueness_of" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub!(:validators).and_return([])

      subject.instances(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      validation = double("validation", :class => ActiveRecord::Validations::UniquenessValidator)
      model.stub!(:validators).and_return([validation])

      subject.instances(model).should == [validation]
    end

    it "finds other validations, but not uniqueness" do
      model = fake_ar_model("User")
      validation = double("validation", :class => ActiveModel::Validations::FormatValidator)
      model.stub!(:validators).and_return([validation])

      subject.instances(model).should == []
    end
  end

  describe "finding missing indexes" do
    before do
      @validation = double("validation", :class => ActiveRecord::Validations::UniquenessValidator)
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :validators => [@validation])
    end

    it "finds one" do
      @validation.stub!(:attributes => [:email], :options => {})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["email"])]
    end

    it "finds one where the validation has scoped columns" do
      @validation.stub!(:attributes => [:city], :options => {:scope => [:email, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["city", "email", "state"])]
    end

    it "leaves the columns in the given order" do
      @validation.stub!(:attributes => [:email], :options => {:scope => [:city, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["email", "city", "state"])]
    end

    it "finds two where there are multiple attributes" do
      @validation.stub!(:attributes => [:email, :name], :options => {:scope => [:city, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["email", "city", "state"]),
                         ConsistencyFail::Index.new("users", ["name", "city", "state"])]
    end

    it "finds none when they're already in place" do
      @validation.stub!(:attributes => [:email], :options => {})
      index = fake_index_on(["email"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes(@model).should == []
    end

    it "finds none when indexes are there but in a different order" do
      @validation.stub!(:attributes => [:email], :options => {:scope => [:city, :state]})
      index = fake_index_on(["state", "email", "city"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes(@model).should == []
    end
  end
end
