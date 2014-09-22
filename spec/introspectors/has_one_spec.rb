require 'spec_helper'
require 'consistency_fail/introspectors/table_data'
require 'consistency_fail/introspectors/has_one'

describe ConsistencyFail::Introspectors::HasOne do
  def introspector(model)
    ConsistencyFail::Introspectors::HasOne.new(model)
  end

  describe "instances of has_one" do
    it "finds none" do
      model = fake_ar_model("User")
      allow(model).to receive(:reflect_on_all_associations).and_return([])

      expect(subject.instances(model)).to eq([])
    end

    it "finds one" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {})
      allow(model).to receive(:reflect_on_all_associations).and_return([association])

      expect(subject.instances(model)).to eq([association])
    end

    it "finds other associations, but not has_one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :has_many)
      allow(model).to receive(:reflect_on_all_associations).and_return([validation])

      expect(subject.instances(model)).to eq([])
    end

    it "finds one, but it's a polymorphic association" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {:as => "addressable"})
      allow(model).to receive(:reflect_on_all_associations).and_return([association])

      expect(subject.instances(model)).to eq([])
    end

    it "finds one, but it's a :through association" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {:through => :amodel})
      allow(model).to receive(:reflect_on_all_associations).and_return([association])

      expect(subject.instances(model)).to eq([])
    end
  end

  describe "finding missing indexes" do
    before do
      @association = double("association", :macro => :has_one, :options => {})
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :class_name => "User",
                                     :reflect_on_all_associations => [@association])
      @address_class = double("Address Class")
      @address_string = "Address"
    end

    it "finds one" do
      allow(@association).to receive_messages(:table_name => :addresses, :klass => @address_class, :foreign_key => "user_id")
      allow(@address_class).to receive_message_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(fake_ar_model("Address"), "addresses", ["user_id"])])
    end

    it "finds one in Rails 3.0.x (where foreign_key is not defined)" do
      allow(@association).to receive_messages(:table_name => :addresses, :klass => @address_class, :primary_key_name => "user_id")
      allow(@address_class).to receive_message_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(fake_ar_model("Address"), "addresses", ["user_id"])])
    end

    it "finds none when they're already in place" do
      allow(@association).to receive_messages(:table_name => :addresses, :klass => @address_class, :foreign_key => "user_id")
      index = ConsistencyFail::Index.new(double('model'), "addresses", ["user_id"])

      fake_connection = double("connection")
      allow(@address_class).to receive_message_chain(:connection).and_return(fake_connection)

      allow(ConsistencyFail::Introspectors::TableData).to receive_message_chain(:new, :unique_indexes_by_table).
        with(@address_class, fake_connection, "addresses").
        and_return([index])

      expect(subject.missing_indexes(@model)).to eq([])
    end
  end
end
