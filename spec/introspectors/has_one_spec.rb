describe ConsistencyFail::Introspectors::HasOne do
  
  describe "finding missing indexes" do
    it "finds one" do
      indexes = subject.missing_indexes(WrongUser)
      
      expect(indexes).to eq([
        ConsistencyFail::Index.new(
          WrongAddress, 
          WrongAddress.table_name, 
          ["wrong_user_id"]
        )
      ])
    end
    
    it "finds none when they're already in place" do
      expect(subject.missing_indexes(CorrectUser)).to eq([])
    end
  end
  
end
