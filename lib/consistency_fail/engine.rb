require 'active_record'

module ConsistencyFail
  class Engine
    def models
      Kernel::subclasses_of(ActiveRecord::Base).sort_by(&:name)
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
        [v.name, *scoped_columns].map(&:to_s)
      end

      existing_indexes = unique_indexes_on(model).map(&:columns).map(&:sort)

      desired_indexes.reject do |columns|
        existing_indexes.include?(columns.sort)
      end
    end
  end
end
