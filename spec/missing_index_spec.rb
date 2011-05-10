require 'spec_helper'
require 'consistency_fail/engine'

describe ConsistencyFail::Engine do
  def fake_ar_model(name, options = {})
    double("AR model: #{name}", options.merge(:name => name))
  end

  def fake_unique_index(columns)
    double("index on #{columns.inspect}", :unique => true, :columns => columns)
  end

  def stub_ar_subclasses!(models)
    Kernel.stub!(:subclasses_of).
           with(ActiveRecord::Base).
           and_return(models)
  end

  it "gets all models" do
    models = [fake_ar_model("Job"), fake_ar_model("User")]
    stub_ar_subclasses!(models)

    subject.models.should == models
  end

  it "sorts models by name" do
    model_1, model_2 = fake_ar_model("User"), fake_ar_model("Job")
    stub_ar_subclasses!([model_1, model_2])

    subject.models.should == [model_2, model_1]
  end

  describe "listing validates_uniqueness_of calls for a given model" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub!(:reflect_on_all_validations).and_return([])

      subject.uniqueness_validations_on(model).should == []
    end

    it "finds other validations, but not uniqueness" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_format_of)
      model.stub!(:reflect_on_all_validations).and_return([])

      subject.uniqueness_validations_on(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :validates_uniqueness_of)
      model.stub!(:reflect_on_all_validations).and_return([validation])

      subject.uniqueness_validations_on(model).should == [validation]
    end
  end

  describe "finding unique indexes" do
    it "finds none when the table does not exist" do
      model = fake_ar_model("User", :table_exists? => false)

      subject.unique_indexes_on(model).should == []
    end

    it "gets unique indexes for a model" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")
      indexes = [fake_unique_index(["a"]), fake_unique_index(["b", "c"])]
      model.stub_chain(:connection, :indexes).
            with("users").
            and_return(indexes)

      subject.unique_indexes_on(model).should == indexes
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

      subject.missing_indexes_on(@model).should == [["email"]]
    end

    it "finds one where the validation has scoped columns" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      @model.stub_chain(:connection, :indexes).with("users").and_return([])

      subject.missing_indexes_on(@model).should == [["email", "city", "state"]]
    end

    it "finds none when they're already in place" do
      @validation.stub!(:name => :email, :options => {})
      index = fake_unique_index(["email"])
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes_on(@model).should == []
    end

    it "finds none when indexes are there but in a different order" do
      @validation.stub!(:name => :email, :options => {:scope => [:city, :state]})
      index = fake_unique_index(["state", "email", "city"])
      @model.stub_chain(:connection, :indexes).with("users").
             and_return([index])

      subject.missing_indexes_on(@model).should == []
    end
  end

end
