describe ConsistencyFail::Introspectors::ValidatesUniquenessOf do
  
  describe "finding missing indexes" do
    it "finds one" do
      indexes = subject.missing_indexes(WrongAccount)
      
      expect(indexes).to eq([
        ConsistencyFail::Index.new(
          WrongAccount, 
          WrongAccount.table_name, 
          ["email"]
        )
      ])
    end

    it "finds one where the validation has scoped columns" do
      indexes = subject.missing_indexes(WrongBusiness)
      
      expect(indexes).to eq([
        ConsistencyFail::Index.new(
          WrongBusiness, 
          WrongBusiness.table_name, 
          ["name", "city", "state"]
        )
      ])
    end

    it "finds two where there are multiple attributes" do
      indexes = subject.missing_indexes(WrongPerson)
      
      expect(indexes).to eq(
        [
          ConsistencyFail::Index.new(
            WrongPerson, 
            WrongPerson.table_name, 
            ["email", "city", "state"]
          ),
          ConsistencyFail::Index.new(
            WrongPerson, 
            WrongPerson.table_name, 
            ["name", "city", "state"]
          )
        ]
      )
    end

    it "finds none when they're already in place" do
      expect(subject.missing_indexes(CorrectAccount)).to be_empty
    end

    it "finds none when indexes are there but in a different order" do
      expect(subject.missing_indexes(CorrectPerson)).to be_empty
    end
  end
  
end
