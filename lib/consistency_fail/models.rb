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

#    # TODO: test
#    def has_one_calls_on(model)
#      model.reflect_on_all_associations.select do |a|
#        a.macro == :has_one
#      end
#    end
#
#    # TODO: handle has_one :through cases (multicolumn index on the join table?)
#    def desired_indexes_for_has_one_on(model)
#      has_one_calls_on(model).map do |v|
#        ConsistencyFail::Index.new(v.table_name, [v.primary_key_name]) rescue nil
#      end.compact
#    end
#    private :desired_indexes_for_has_one_on
#
#    def missing_indexes_for_has_one_on(model)
#      existing_indexes = unique_indexes_on(model)
#
#      desired_indexes_for_has_one_on(model).reject do |index|
#        existing_indexes.include?(index)
#      end
#    end

  end
end
