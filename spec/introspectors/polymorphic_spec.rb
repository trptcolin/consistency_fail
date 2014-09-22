require 'spec_helper'
require 'consistency_fail/introspectors/table_data'
require 'consistency_fail/introspectors/polymorphic'

describe ConsistencyFail::Introspectors::Polymorphic do
  def introspector(model)
    ConsistencyFail::Introspectors::Polymorphic.new(model)
  end

  describe "instances of polymorphic" do
    it "finds none" do
      model = fake_ar_model("User")
      allow(model).to receive(:reflect_on_all_associations).and_return([])

      expect(subject.instances(model)).to eq([])
    end

    it "finds one" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one, :options => {:as => "addressable"})
      allow(model).to receive(:reflect_on_all_associations).and_return([association])

      expect(subject.instances(model)).to eq([association])
    end

    it "finds other has_one associations, but not polymorphic" do
      model = fake_ar_model("User")
      validation = double("association", :macro => :has_one, :options => {})
      allow(model).to receive(:reflect_on_all_associations).and_return([validation])

      expect(subject.instances(model)).to eq([])
    end

    it "finds other non has_one associations" do
      model = fake_ar_model("User")
      validation = double("association", :macro => :has_many)
      allow(model).to receive(:reflect_on_all_associations).and_return([validation])

      expect(subject.instances(model)).to eq([])
    end
  end

  describe "finding missing indexes" do
    before do
      @association = double("association", :macro => :has_one, :options => {:as => "addressable"})
      @model = fake_ar_model("User", :table_exists? => true,
                                     :table_name => "users",
                                     :class_name => "User",
                                     :reflect_on_all_associations => [@association])
      @address_class = double("Address Class")
      @address_string = "Address"
    end

    it "finds one" do
      allow(@association).to receive_messages(:table_name => :addresses, :klass => @address_class)
      allow(@address_class).to receive_message_chain(:connection, :indexes).with("addresses").and_return([])

      indexes = subject.missing_indexes(@model)
      expect(indexes).to eq([ConsistencyFail::Index.new(fake_ar_model("Address"), "addresses", ["addressable_type", "addressable_id"])])
    end

    it "finds none when they're already in place" do
      allow(@association).to receive_messages(:table_name => :addresses, :klass => @address_class)
      index = ConsistencyFail::Index.new(double('model'), "addresses", ["addressable_type", "addressable_id"])

      fake_connection = double("connection")
      allow(@address_class).to receive_message_chain(:connection).and_return(fake_connection)

      allow(ConsistencyFail::Introspectors::TableData).to receive_message_chain(:new, :unique_indexes_by_table).
        with(@address_class, fake_connection, "addresses").
        and_return([index])

      expect(subject.missing_indexes(@model)).to eq([])
    end
  end
end
