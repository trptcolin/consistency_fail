require 'consistency_fail/reporters/base'

module ConsistencyFail
  module Reporters
    class HasOne < Base
      attr_reader :macro

      def initialize
        @macro = :has_one
      end

      def report_index(model, index, column_1_length)
        print model.name.ljust(column_1_length + 2)
        puts "#{index.table_name}: (#{index.columns.join(", ")})"
      end

      def column_1(model)
        model.name
      end

      def column_headers
        ["Offending Model", "Desired Unique Index"]
      end
    end
  end
end
