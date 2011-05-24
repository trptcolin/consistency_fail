require 'spec_helper'
require 'consistency_fail/introspectors/has_one'

describe ConsistencyFail::Introspectors::HasOne do
  def introspector(model)
    ConsistencyFail::Introspectors::HasOne.new(model)
  end

  describe "instances of has_one" do
    it "finds none" do
      model = fake_ar_model("User")
      model.stub(:reflect_on_all_associations).and_return([])

      subject.instances(model).should == []
    end

    it "finds one" do
      model = fake_ar_model("User")
      association = double("association", :macro => :has_one)
      model.stub!(:reflect_on_all_associations).and_return([association])

      subject.instances(model).should == [association]
    end

    it "finds other associations, but not has_one" do
      model = fake_ar_model("User")
      validation = double("validation", :macro => :has_many)
      model.stub!(:reflect_on_all_associations).and_return([validation])

      subject.instances(model).should == []
    end
  end
end


