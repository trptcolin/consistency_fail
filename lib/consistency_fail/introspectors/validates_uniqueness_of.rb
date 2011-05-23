require 'consistency_fail/engine'
require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class ValidatesUniquenessOf
      def instances(model)
        model.reflect_on_all_validations.select do |v|
          v.macro == :validates_uniqueness_of
        end
      end

      def desired_indexes(model)
        instances(model).map do |v|
          scoped_columns = v.options[:scope] || []
          ConsistencyFail::Index.new(model.table_name, [v.name, *scoped_columns])
        end
      end
      private :desired_indexes

      def missing_indexes(model)
        existing_indexes = ConsistencyFail::Engine.new.unique_indexes_on(model)

        desired_indexes(model).reject do |index|
          existing_indexes.include?(index)
        end
      end
    end
  end
end
