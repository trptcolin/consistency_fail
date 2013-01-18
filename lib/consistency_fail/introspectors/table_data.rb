require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class TableData
      def unique_indexes(model)
        return [] if !model.table_exists?

        unique_indexes_by_table(model, model.connection, model.table_name)
      end

      def unique_indexes_by_table(model, connection, table_name)
        ar_indexes = connection.indexes(table_name).select(&:unique)
        result = ar_indexes.map do |index|
          ConsistencyFail::Index.new(model,
                                     table_name,
                                     index.columns)
        end
        result
      end
    end
  end
end
