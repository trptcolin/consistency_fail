require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class Polymorphic
      def instances(model)
        model.reflect_on_all_associations.select do |a|
          a.macro == :has_one && a.options[:as].to_s.length > 0
        end
      end

      def desired_indexes(model)
        instances(model).map do |a|
          as      = a.options[:as]
          as_type = "#{as}_type"
          as_id   = "#{as}_id"

          ConsistencyFail::Index.new(
            a.klass,
            a.table_name.to_s,
            [as_type, as_id]
          )
        end.compact
      end
      private :desired_indexes

      def missing_indexes(model)
        desired = desired_indexes(model)

        existing_indexes = desired.inject([]) do |acc, d|
          acc += TableData.new.unique_indexes_by_table(d.model,
                                                       d.model.connection,
                                                       d.table_name)
        end

        desired.reject do |index|
          existing_indexes.include?(index)
        end
      end
    end
  end
end
