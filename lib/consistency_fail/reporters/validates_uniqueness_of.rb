require 'consistency_fail/reporters/base'

module ConsistencyFail
  module Reporters
    class ValidatesUniquenessOf < Base
      attr_reader :macro

      def initialize
        @macro = :validates_uniqueness_of
      end

      def report_index(model, index, column_1_length)
        print index.table_name.ljust(column_1_length + 2)
        puts "(#{index.columns.join(", ")})"
      end

      def column_1(model)
        model.table_name
      end

      def column_headers
        ["Table", "Columns (multicolumn order is alphabetical)"]
      end

    end
  end
end
