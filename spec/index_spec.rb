require 'spec_helper'
require 'consistency_fail/index'

describe ConsistencyFail::Index do

  describe "value objectiness" do
    it "holds onto model, table name, and columns" do
      model = double("model")
      index = ConsistencyFail::Index.new(model, "addresses", ["city", "state"])
      expect(index.model).to eq(model)
      expect(index.table_name).to eq("addresses")
      expect(index.columns).to eq(["city", "state"])
    end

    it "leaves columns in the initial order (since we only care about presence, not performance)" do
      index = ConsistencyFail::Index.new(double('model'), "addresses", ["state", "city"])
      expect(index.columns).to eq(["state", "city"])
    end
  end

  describe "equality test" do
    it "passes when everything matches" do
      expect(ConsistencyFail::Index.new(double('model'), "addresses", ["city", "state"])).to eq(
        ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"])
      )
    end

    it "fails when tables are different" do
      expect(ConsistencyFail::Index.new(double('model'),"locations", ["city", "state"])).not_to eq(
        ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"])
      )
    end

    it "fails when columns are different" do
      expect(ConsistencyFail::Index.new(double('model'),"addresses", ["city", "state"])).not_to eq(
        ConsistencyFail::Index.new(double('model'),"addresses", ["state", "zip"])
      )
    end
  end
end
