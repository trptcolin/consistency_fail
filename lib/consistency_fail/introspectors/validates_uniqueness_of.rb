require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class ValidatesUniquenessOf
      def instances(model)
        model.validators.select do |v|
          v.class == ActiveRecord::Validations::UniquenessValidator
        end
      end

      def desired_indexes(model)
        instances(model).map do |v|
          v.attributes.map do |attribute|
            scoped_columns = v.options[:scope] || []
            ConsistencyFail::Index.new(model.table_name, [attribute, *scoped_columns])
          end
        end.flatten
      end
      private :desired_indexes

      def missing_indexes(model)
        existing_indexes = TableData.new.unique_indexes(model)

        desired_indexes(model).reject do |index|
          existing_indexes.include?(index)
        end
      end
    end
  end
end
