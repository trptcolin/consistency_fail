require 'active_record'

module ConsistencyFail
  class Engine
    MODEL_DIRECTORY_REGEXP = /models/

    def preload_all_models
      model_dirs = Rails.configuration.load_paths.select{|lp| MODEL_DIRECTORY_REGEXP =~ lp}
      model_dirs.each do |d|
        Dir.glob(File.join(d, "**", "*.rb")).each do |model_filename|
          require_dependency model_filename
        end
      end
    end

    def models
      models = []
      ObjectSpace.each_object do |o|
        models << o if o.class == Class &&
                       o.ancestors.include?(ActiveRecord::Base) &&
                       o != ActiveRecord::Base
      end
      models.sort_by(&:name)
    end

    def uniqueness_validations_on(model)
      model.reflect_on_all_validations.select do |v|
        v.macro == :validates_uniqueness_of
      end
    end

    def unique_indexes_on(model)
      return [] if !model.table_exists?

      model.connection.indexes(model.table_name).select(&:unique)
    end

    def missing_indexes_on(model)
      desired_indexes = uniqueness_validations_on(model).map do |v|
        scoped_columns = v.options[:scope] || []
        [v.name, *scoped_columns].map(&:to_s).sort
      end

      existing_indexes = unique_indexes_on(model).map(&:columns).map(&:sort)

      desired_indexes.reject do |columns|
        existing_indexes.include?(columns.sort)
      end
    end
  end
end
