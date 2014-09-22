require 'spec_helper'
require 'consistency_fail/introspectors/validates_uniqueness_of'

describe ConsistencyFail::Introspectors::ValidatesUniquenessOf do
  def introspector(model)
    ConsistencyFail::Introspectors::ValidatesUniquenessOf.new(model)
  end

  describe "instances of validates_uniqueness_of" do
    it "finds none" do
      model = fake_ar_model("User")
      allow(model).to receive(:validators).and_return([])

      expect(subject.instances(model)).to eq([])
    end

    it "finds one" do
      model = fake_ar_model("User")
      validation = double("validation", :class => ActiveRecord::Validations::UniquenessValidator)
      allow(model).to receive(:validators).and_return([validation])

      expect(subject.instances(model)).to eq([validation])
    end

    it "finds other validations, but not uniqueness" do
      model = fake_ar_model("User")
      validation = double("validation", :class => ActiveModel::Validations::FormatValidator)
      allow(model).to receive(:validators).and_return([validation])

      expect(subject.instances(model)).to eq([])
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
      allow(@validation).to receive_messages(:attributes => [:email], :options => {})
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(double('model'), "users", ["email"])])
    end

    it "finds one where the validation has scoped columns" do
      allow(@validation).to receive_messages(:attributes => [:city], :options => {:scope => [:email, :state]})
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(double('model'), "users", ["city", "email", "state"])])
    end

    it "leaves the columns in the given order" do
      allow(@validation).to receive_messages(:attributes => [:email], :options => {:scope => [:city, :state]})
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(double('model'), "users", ["email", "city", "state"])])
    end

    it "finds two where there are multiple attributes" do
      allow(@validation).to receive_messages(:attributes => [:email, :name], :options => {:scope => [:city, :state]})
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(double('model'), "users", ["email", "city", "state"]),
                         ConsistencyFail::Index.new(double('model'), "users", ["name", "city", "state"])])
    end

    it "finds none when they're already in place" do
      allow(@validation).to receive_messages(:attributes => [:email], :options => {})
      index = fake_index_on(["email"], :unique => true)
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").
             and_return([index])

      expect(subject.missing_indexes(@model)).to eq([])
    end

    it "finds none when indexes are there but in a different order" do
      allow(@validation).to receive_messages(:attributes => [:email], :options => {:scope => [:city, :state]})
      index = fake_index_on(["state", "email", "city"], :unique => true)
      allow(@model).to receive_message_chain(:connection, :indexes).with("users").
             and_return([index])

      expect(subject.missing_indexes(@model)).to eq([])
    end
  end
end
