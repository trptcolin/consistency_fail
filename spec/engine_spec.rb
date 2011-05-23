require 'spec_helper'
require 'consistency_fail/engine'

describe ConsistencyFail::Engine do
  def fake_ar_model(name, options = {})
    double("AR model: #{name}", options.merge(:name => name))
  end

  def fake_index_on(columns, options = {})
    double("index on #{columns.inspect}", options.merge(:columns => columns))
  end

  describe "finding unique indexes" do
    it "finds none when the table does not exist" do
      model = fake_ar_model("User", :table_exists? => false)

      subject.unique_indexes_on(model).should == []
    end

    it "gets one" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => true)])

      indexes = subject.unique_indexes_on(model)
      indexes.should == [ConsistencyFail::Index.new("users", ["a"])]
    end

    it "doesn't get non-unique indexes" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => false)])

      subject.unique_indexes_on(model).should == []
    end

    it "gets multiple unique indexes" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => true),
                        fake_index_on(["b", "c"], :unique => true)])

      indexes = subject.unique_indexes_on(model)
      indexes.size.should == 2
      indexes.should == [ConsistencyFail::Index.new("users", ["a"]),
                         ConsistencyFail::Index.new("users", ["b", "c"])]
    end
  end

  describe "listing validates_uniqueness_of calls for a given model" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub!(:reflect_on_all_validations).and_return([])

      subject.uniqueness_validations_on(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_uniqueness_of)
      model.stub!(:reflect_on_all_validations).and_return([validation])

      subject.uniqueness_validations_on(model).should == [validation]
    end

    it "finds other validations, but not uniqueness" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_format_of)
      model.stub!(:reflect_on_all_validations).and_return([])

      subject.uniqueness_validations_on(model).should == []
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

      indexes = subject.missing_indexes_for_validates_uniqueness_on(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["email"])]
    end

    it "finds one where the validation has scoped columns" do
      @validation.stub!(:name => :city, :options => {:scope => [:email, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes_for_validates_uniqueness_on(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["city", "email", "state"])]
    end

    it "sorts the scoped columns" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes_for_validates_uniqueness_on(@model)
      indexes.should == [ConsistencyFail::Index.new("users", ["city", "email", "state"])]
    end

    it "finds none when they're already in place" do
      @validation.stub!(:name => :email, :options => {})
      index = fake_index_on(["email"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes_for_validates_uniqueness_on(@model).should == []
    end

    it "finds none when indexes are there but in a different order" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      index = fake_index_on(["state", "email", "city"], :unique => true)
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes_for_validates_uniqueness_on(@model).should == []
    end
  end

end
