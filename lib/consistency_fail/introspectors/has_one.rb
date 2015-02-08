require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class HasOne
      def instances(model)
        model.reflect_on_all_associations.select do |a|
          a.macro == :has_one && a.options[:as].to_s.length == 0 && a.options[:through].to_s.length == 0
        end
      end

      # TODO: handle has_one :through cases (multicolumn index on the join table?)
      def desired_indexes(model)
        instances(model).map do |a|
          if a.respond_to?(:foreign_key)
            foreign_key = a.foreign_key
          else
            foreign_key = a.primary_key_name
          end
          ConsistencyFail::Index.new(a.klass,
                                     a.table_name.to_s,
                                     [foreign_key])
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
