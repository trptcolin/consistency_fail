require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class HasOne

      def instances(model)
        model.reflect_on_all_associations.select do |a|
          a.macro == :has_one
        end
      end

      # TODO: handle has_one :through cases (multicolumn index on the join table?)
      def desired_indexes(model)
        instances(model).map do |a|
          ConsistencyFail::Index.new(a.table_name.to_s, [a.primary_key_name]) rescue nil
        end.compact
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
