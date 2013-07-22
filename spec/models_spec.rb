require 'spec_helper'
require 'consistency_fail/models'

describe ConsistencyFail::Models do
  def models(load_path)
    ConsistencyFail::Models.new(load_path)
  end

  it "gets the load path" do
    models([:a, :b, :c]).load_path.should == [:a, :b, :c]
  end

  it "gets the directories matching /models/" do
    models = models(["foo/bar/baz", "app/models", "some/other/models"])
    models.dirs.should == ["app/models", "some/other/models"]
  end

  it "accepts and matches path names as well as strings" do
    models = models([Pathname.new("app/models")])
    lambda { models.dirs }.should_not raise_error(TypeError)
    models.dirs.should == ["app/models"]
  end

  it "preloads models by calling require_dependency" do
    models = models(["foo/bar/baz", "app/models", "some/other/models"])
    Dir.stub(:glob).
        with(File.join("app/models", "**", "*.rb")).
        and_return(["app/models/user.rb", "app/models/address.rb"])
    Dir.stub(:glob).
        with(File.join("some/other/models", "**", "*.rb")).
        and_return(["some/other/models/foo.rb"])

    Kernel.should_receive(:require_dependency).with("app/models/user.rb")
    Kernel.should_receive(:require_dependency).with("app/models/address.rb")
    Kernel.should_receive(:require_dependency).with("some/other/models/foo.rb")

    models.preload_all
  end

  it "gets all models" do
    model_a = double(:name => "animal")
    model_b = double(:name => "cat")
    model_c = double(:name => "beach_ball")

    ActiveRecord::Base.stub(:send).with(:descendants).and_return([model_a, model_b, model_c])

    models([]).all.should == [model_a, model_c, model_b]
  end
end
