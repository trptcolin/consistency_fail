require 'spec_helper'
require 'consistency_fail/reporter'
require 'consistency_fail/index'

describe ConsistencyFail::Reporter do
  before(:each) do
    @real_out = $stdout
    @fake_out = StringIO.new
    $stdout = @fake_out
  end
  after(:each) do
    $stdout = @real_out
  end

  context "validates_uniqueness_of" do
    it "says everything's good" do
      subject.report_validates_uniqueness_problems([])

      @fake_out.string.should =~ /Hooray!/
    end

    it "shows a missing single-column index on a single model" do
      missing_indexes = [ConsistencyFail::Index.new(double('model'), "users", ["email"])]

      subject.report_validates_uniqueness_problems(fake_ar_model("User", :table_name => "users") => missing_indexes)

      @fake_out.string.should =~ /users\s+\(email\)/
    end

    it "shows a missing multiple-column index on a single model" do
      missing_indexes = [ConsistencyFail::Index.new(double('model'),"addresses", ["number", "street", "zip"])]

      subject.report_validates_uniqueness_problems(fake_ar_model("Address", :table_name => "addresses") => missing_indexes)

      @fake_out.string.should =~ /addresses\s+\(number, street, zip\)/
    end

    context "with problems on multiple models" do
      before(:each) do
        subject.report_validates_uniqueness_problems(
          fake_ar_model("User", :table_name => "users") =>
            [ConsistencyFail::Index.new(double('model'),"users", ["email"])],
          fake_ar_model("Citizen", :table_name => "citizens") =>
            [ConsistencyFail::Index.new(double('model'),"citizens", ["ssn"])]
        )
      end

      it "shows all problems" do
        @fake_out.string.should =~ /users\s+\(email\)/m
        @fake_out.string.should =~ /citizens\s+\(ssn\)/m
      end

      it "orders the models alphabetically" do
        @fake_out.string.should =~ /citizens\s+\(ssn\).*users\s+\(email\)/m
      end
    end
  end

  context "has_one" do
    it "says everything's good" do
      subject.report_has_one_problems([])

      @fake_out.string.should =~ /Hooray!/
    end

    it "shows a missing single-column index on a single model" do
      missing_indexes = [ConsistencyFail::Index.new(double('model'),"users", ["email"])]

      subject.report_has_one_problems(fake_ar_model("Friend", :table_name => "users") => missing_indexes)

      @fake_out.string.should =~ /Friend\s+users\s+\(email\)/m
    end
  end

  context "polymorphic" do
    it "says everything's good" do
      subject.report_polymorphic_problems([])

      @fake_out.string.should =~ /Hooray!/
    end

    it "shows a missing compound index on a single model" do
      missing_indexes = [ConsistencyFail::Index.new(double('model'), "addresses", ["addressable_type", "addressable_id"])]

      subject.report_polymorphic_problems(fake_ar_model("Address", :table_name => "addresses") => missing_indexes)

      @fake_out.string.should =~ /Address\s+addresses\s+\(addressable_type, addressable_id\)/m
    end
  end
end
