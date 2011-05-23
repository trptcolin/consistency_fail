require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class TableData
      def unique_indexes(model)
        return [] if !model.table_exists?

        ar_indexes = model.connection.indexes(model.table_name).select(&:unique)
        ar_indexes.map do |index|
          ConsistencyFail::Index.new(model.table_name, index.columns)
        end
      end
    end
  end
end
