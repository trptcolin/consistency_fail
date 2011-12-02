require 'active_record'
require 'consistency_fail/index'

module ConsistencyFail
  class Models
    MODEL_DIRECTORY_REGEXP = /models/

    attr_reader :load_path

    def initialize(load_path)
      @load_path = load_path
    end

    def dirs
      load_path.select { |lp| MODEL_DIRECTORY_REGEXP =~ lp }
    end

    def preload_all
      self.dirs.each do |d|
        Dir.glob(File.join(d, "**", "*.rb")).each do |model_filename|
          Kernel.require_dependency model_filename
        end
      end
    end

    def all
      ActiveRecord::Base.send(:descendants).sort_by(&:name)
    end

  end
end
