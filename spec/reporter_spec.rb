describe ConsistencyFail::Reporter do
  
  context "validates_uniqueness_of" do
    it "says everything's good" do
      expect { 
        subject.report_validates_uniqueness_problems([]) 
      }.to output(/Hooray!/).to_stdout
    end

    it "shows a missing single-column index on a single model" do
      missing_indexes = [
        ConsistencyFail::Index.new(
          WrongAccount, 
          WrongAccount.table_name, 
          ["email"]
        )
      ]

      expect { 
        subject.report_validates_uniqueness_problems(
          WrongAccount => missing_indexes
        )
      }.to output(/wrong_accounts\s+\(email\)/).to_stdout
    end

    it "shows a missing multiple-column index on a single model" do
      missing_indexes = [
        ConsistencyFail::Index.new(
          WrongBusiness, 
          WrongBusiness.table_name, 
          ["name", "city", "state"]
        )
      ]

      expect {
        subject.report_validates_uniqueness_problems(
          WrongBusiness => missing_indexes
        )
      }.to output(/wrong_businesses\s+\(name, city, state\)/).to_stdout
    end

    context "with problems on multiple models" do
      def report
        missing_indices = {
          WrongAccount => [
            ConsistencyFail::Index.new(
              WrongAccount, 
              WrongAccount.table_name, 
              ["email"]
            )
          ],
          WrongBusiness => [
            ConsistencyFail::Index.new(
              WrongBusiness, 
              WrongBusiness.table_name, 
              ["name", "city", "state"]
            )
          ]
        }
        
        subject.report_validates_uniqueness_problems(missing_indices)
      end

      it "shows all problems" do
        expect { report }.to output(/wrong_accounts\s+\(email\)/).to_stdout
        expect { report }.to output(
          /wrong_businesses\s+\(name, city, state\)/
        ).to_stdout
      end

      it "orders the models alphabetically" do
        expect { report }.to output(/
          wrong_accounts\s+\(email\)
          (\s|\S)*
          wrong_businesses\s+\(name,\scity,\sstate\)
        /x).to_stdout
      end
    end
  end

  context "has_one" do
    it "says everything's good" do
      expect { 
        subject.report_has_one_problems([]) 
      }.to output(/Hooray!/).to_stdout
    end

    it "shows a missing single-column index on a single model" do
      missing_indexes = [
        ConsistencyFail::Index.new(
          WrongAddress, 
          WrongAddress.table_name, 
          ["wrong_user_id"]
        )
      ]

      expect {
        subject.report_has_one_problems(WrongAddress => missing_indexes)
      }.to output(/wrong_addresses\s+\(wrong_user_id\)/).to_stdout
    end
  end

  context "polymorphic" do
    it "says everything's good" do
      expect {
        subject.report_polymorphic_problems([])
      }.to output(/Hooray!/).to_stdout
    end

    it "shows a missing compound index on a single model" do
      missing_indexes = [
        ConsistencyFail::Index.new(
          WrongAttachment, 
          WrongAttachment.table_name, 
          ["attachable_type", "attachable_id"]
        )
      ]

      expect {
        subject.report_polymorphic_problems(WrongAttachment => missing_indexes)
      }.to(
        output(
          /wrong_attachments\s+\(attachable_type, attachable_id\)/
        ).to_stdout
      )
    end
  end
  
end
