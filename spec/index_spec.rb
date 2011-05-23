require 'spec_helper'
require 'consistency_fail/index'

describe ConsistencyFail::Index do

  describe "value objectiness" do
    it "holds onto table name and columns" do
      index = ConsistencyFail::Index.new("addresses", ["city", "state"])
      index.table_name.should == "addresses"
      index.columns.should == ["city", "state"]
    end

    it "sorts columns (since we only care about presence, not performance)" do
      index = ConsistencyFail::Index.new("addresses", ["state", "city"])
      index.table_name.should == "addresses"
      index.columns.should == ["city", "state"]
    end
  end

  describe "equality test" do
    it "passes when everything matches" do
      ConsistencyFail::Index.new("addresses", ["city", "state"]).should ==
        ConsistencyFail::Index.new("addresses", ["city", "state"])
    end

    it "fails when tables are different" do
      ConsistencyFail::Index.new("locations", ["city", "state"]).should_not ==
        ConsistencyFail::Index.new("addresses", ["city", "state"])
    end

    it "fails when columns are different" do
      ConsistencyFail::Index.new("addresses", ["city", "state"]).should_not ==
        ConsistencyFail::Index.new("addresses", ["state", "zip"])
    end
  end
end
