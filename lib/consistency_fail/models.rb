require 'active_record'
require 'consistency_fail/index'

module ConsistencyFail
  class Models
    MODEL_DIRECTORY_REGEXP = /models/

    def self.model_dirs
      $LOAD_PATH.select { |lp| MODEL_DIRECTORY_REGEXP =~ lp }
    end

    def self.preload_all
      self.model_dirs.each do |d|
        Dir.glob(File.join(d, "**", "*.rb")).each do |model_filename|
          Kernel.require_dependency model_filename
        end
      end
    end

    def self.all
      models = []
      ObjectSpace.each_object do |o|
        models << o if o.class == Class &&
                       o.ancestors.include?(ActiveRecord::Base) &&
                       o != ActiveRecord::Base
      end
      models.sort_by(&:name)
    end

  end
end
