module ConsistencyFail
  module Reporters
    class Base
      TERMINAL_WIDTH = 80

      RED = 31
      GREEN = 32

      def use_color(code)
        print "\e[#{code}m"
      end

      def use_default_color
        use_color(0)
      end

      def report_success(macro)
        use_color(GREEN)
        puts "Hooray! All calls to #{macro} are correctly backed by a unique index."
        use_default_color
      end

      def divider(pad_to = TERMINAL_WIDTH)
        puts "-" * [pad_to, TERMINAL_WIDTH].max
      end

      def report_failure_header(macro, longest_model_length)
        puts
        use_color(RED)
        puts "There are calls to #{macro} that aren't backed by unique indexes."
        use_default_color
        divider(longest_model_length * 2)

        column_1_header, column_2_header = column_headers
        print column_1_header.ljust(longest_model_length + 2)
        puts column_2_header

        divider(longest_model_length * 2)
      end

      def report_index(model, index, column_1_length)
        print model.name.ljust(column_1_length + 2)
        puts "#{index.table_name} (#{index.columns.join(", ")})"
      end

      def column_1(model)
        model.name
      end

      def column_headers
        ["Model", "Table Columns"]
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
