describe ConsistencyFail::Introspectors::Polymorphic do

  describe "finding missing indexes" do
    it "finds one" do
      indexes = subject.missing_indexes(WrongPost)

      expect(indexes).to eq([
        ConsistencyFail::Index.new(
          WrongAttachment,
          WrongAttachment.table_name,
          ["attachable_type", "attachable_id"]
        )
      ])
    end

    it "finds none when they're already in place" do
      expect(subject.missing_indexes(CorrectPost)).to be_empty
    end

    it "finds none with nested modules" do
      expect(subject.missing_indexes(CorrectUser)).to eq([])
    end

  end

end
