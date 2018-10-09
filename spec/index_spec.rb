require_relative 'support/models/correct_address'
require_relative 'support/models/wrong_address'

describe ConsistencyFail::Index do

  let(:index) do
    ConsistencyFail::Index.new(
      CorrectAddress,
      CorrectAddress.table_name,
      ["city", "state"]
    )
  end

  describe "value objectiness" do
    it "holds onto model, table name, and columns" do
      expect(index.model).to eq(CorrectAddress)
      expect(index.table_name).to eq("correct_addresses")
      expect(index.columns).to eq(
        ["city", "state"]
      )
    end

    it "leaves columns in the initial order (since we only care about presence, not performance)" do
      expect(index.columns).to eq(
        ["city", "state"]
      )
    end
  end

  describe "equality test" do
    it "passes when everything matches" do
      expect(index).to eq(
        ConsistencyFail::Index.new(
          "CorrectAddress".constantize,
          "correct_addresses",
          ["city", "state"]
        )
      )
    end

    it "fails when tables are different" do
      expect(index).not_to eq(
        ConsistencyFail::Index.new(
          CorrectAttachment,
          CorrectAttachment.table_name,
          ["attachable_id", "attachable_type"]
        )
      )
    end

    it "fails when columns are different" do
      expect(index).not_to eq(
        ConsistencyFail::Index.new(
          CorrectAddress,
          CorrectAddress.table_name,
          ["correct_user_id"]
        )
      )
    end
  end

end
