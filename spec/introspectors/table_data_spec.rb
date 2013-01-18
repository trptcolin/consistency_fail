require 'spec_helper'
require 'consistency_fail/introspectors/table_data'

describe ConsistencyFail::Introspectors::TableData do
  describe "finding unique indexes" do
    it "finds none when the table does not exist" do
      model = fake_ar_model("User", :table_exists? => false)

      subject.unique_indexes(model).should == []
    end

    it "gets one" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => true)])

      indexes = subject.unique_indexes(model)
      indexes.should == [ConsistencyFail::Index.new(double('model'), "users", ["a"])]
    end

    it "doesn't get non-unique indexes" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => false)])

      subject.unique_indexes(model).should == []
    end

    it "gets multiple unique indexes" do
      model = fake_ar_model("User", :table_exists? => true,
                                    :table_name => "users")

      model.stub_chain(:connection, :indexes).
            with("users").
            and_return([fake_index_on(["a"], :unique => true),
                        fake_index_on(["b", "c"], :unique => true)])

      indexes = subject.unique_indexes(model)
      indexes.size.should == 2
      indexes.should == [ConsistencyFail::Index.new(double('model'), "users", ["a"]),
                         ConsistencyFail::Index.new(double('model'), "users", ["b", "c"])]
    end
  end

end

