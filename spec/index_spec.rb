require 'spec_helper'
require 'consistency_fail/index'

describe ConsistencyFail::Index do

  describe "value objectiness" do
    it "holds onto model, table name, and columns" do
      model = double("model")
      index = ConsistencyFail::Index.new(model, "addresses", ["city", "state"])
      index.model.should == model
      index.table_name.should == "addresses"
      index.columns.should == ["city", "state"]
    end

    it "leaves columns in the initial order (since we only care about presence, not performance)" do
      index = ConsistencyFail::Index.new(double('model'), "addresses", ["state", "city"])
      index.columns.should == ["state", "city"]
    end
  end

  describe "equality test" do
    it "passes when everything matches" do
      ConsistencyFail::Index.new(double('model'), "addresses", ["city", "state"]).should ==
        ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"])
    end

    it "fails when tables are different" do
      ConsistencyFail::Index.new(double('model'),"locations", ["city", "state"]).should_not ==
        ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"])
    end

    it "fails when columns are different" do
      ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"]).should_not ==
        ConsistencyFail::Index.new(double('model'),"addresses", ["state", "zip"])
    end
  end
end
