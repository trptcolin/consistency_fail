module ConsistencyFail
  module Reporters
    class Base
      TERMINAL_WIDTH = 80

      def report_success(macro)
        divider
        puts "Hooray! All #{macro} calls are correctly backed by a unique index."
        divider
      end

      def divider(pad_to = TERMINAL_WIDTH)
        puts "-" * [pad_to, TERMINAL_WIDTH].max
      end

      def report_failure_header(macro, longest_model_length)
        puts
        divider(longest_model_length * 2)
        puts "#{macro} calls not backed by unique indexes"
        divider(longest_model_length * 2)

        column_1_header, column_2_header = column_headers
        print column_1_header.ljust(longest_model_length + 2)
        puts column_2_header

        divider(longest_model_length * 2)
      end

      def report_index(model, index, column_1_header)
        raise "Unimplemented"
      end

      def column_1(model)
        raise "Unimplemented"
      end

      def report(indexes_by_model)
        if indexes_by_model.empty?
          report_success(macro)
        else
          indexes_by_table_name = indexes_by_model.map do |model, indexes|
            [column_1(model), model, indexes]
          end.sort_by(&:first)
          longest_model_length = indexes_by_table_name.map(&:first).
                                                       sort_by(&:length).
                                                       last.
                                                       length
          column_1_header_length = column_headers.first.length
          longest_model_length = [longest_model_length, column_1_header_length].max

          report_failure_header(macro, longest_model_length)

          indexes_by_table_name.each do |table_name, model, indexes|
            indexes.each do |index|
              report_index(model, index, longest_model_length)
            end
          end
          divider(longest_model_length * 2)
        end
        puts
      end
    end
  end
end
