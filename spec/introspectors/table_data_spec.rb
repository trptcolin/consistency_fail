describe ConsistencyFail::Introspectors::TableData do
  
  describe "finding unique indexes" do
    it "finds none when the table does not exist" do
      expect(subject.unique_indexes(Nonexistent)).to be_empty
    end

    it "gets one" do
      index = ConsistencyFail::Index.new(
        CorrectAccount,
        CorrectAccount.table_name,
        ["email"]
      )

      expect(
        ConsistencyFail::Introspectors::TableData.new.unique_indexes_by_table(
          CorrectAccount,
          ActiveRecord::Base.connection,
          CorrectAccount.table_name
        )
      ).to eq [index]
    end

    it "doesn't get non-unique indexes" do
      expect(
        ConsistencyFail::Introspectors::TableData.new.unique_indexes_by_table(
          WrongAddress,
          ActiveRecord::Base.connection,
          WrongAddress.table_name
        )
      ).to be_empty
    end

    it "gets multiple unique indexes" do
      indexes = [
        ConsistencyFail::Index.new(
          CorrectAttachment,
          CorrectAttachment.table_name,
          ["name"]
        ),
        ConsistencyFail::Index.new(
          CorrectAttachment,
          CorrectAttachment.table_name,
          ["attachable_id", "attachable_type"]
        ),
        ConsistencyFail::Index.new(
          CorrectAttachment,
          CorrectAttachment.table_name,
          ["name", "attachable_id", "attachable_type"]
        )
      ]

      expect(
        ConsistencyFail::Introspectors::TableData.new.unique_indexes_by_table(
          CorrectAttachment,
          ActiveRecord::Base.connection,
          CorrectAttachment.table_name
        )
      ).to eq indexes
    end
  end

end
