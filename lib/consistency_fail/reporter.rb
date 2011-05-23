module ConsistencyFail
  class Reporter
    TERMINAL_WIDTH = 80

#    def report_has_one_problems(indexes_by_model)
#      if indexes_by_model.empty?
#        divider
#        puts "Hooray! All has_one calls are correctly backed by a unique index."
#        divider
#      else
#        indexes_by_table_name = indexes_by_model.map do |model, indexes|
#          ["#{model.name}", indexes]
#        end.sort_by(&:first)
#        model_header = "Offending Model"
#        longest_model_length = indexes_by_table_name.map(&:first).
#                                                     sort_by(&:length).
#                                                     last.
#                                                     length
#        longest_model_length = [longest_model_length, model_header.length].max
#
#        puts
#        divider(longest_model_length * 2)
#        puts "has_one calls not backed by unique indexes"
#        divider(longest_model_length * 2)
#        print model_header.ljust(longest_model_length + 2)
#        puts "Desired Unique Index (order is irrelevant)"
#        divider(longest_model_length * 2)
#
#        indexes_by_table_name.each do |table, indexes|
#          indexes.each do |index|
#            print table.ljust(longest_model_length + 2)
#            print "#{index.table_name}: "
#            puts "(#{index.columns.join(", ")})"
#          end
#        end
#        divider(longest_model_length * 2)
#      end
#      puts
#    end

    def report_success(macro)
      divider
      puts "Hooray! All #{macro} calls are correctly backed by a unique index."
      divider
    end

    def column_headers(macro)
      if macro == :validates_uniqueness_of
        ["Table", "Columns (multicolumn order is alphabetical)"]
      else
        []
      end
    end

    def report_failure_header(macro, longest_model_length)
      puts
      divider(longest_model_length * 2)
      puts "#{macro} calls not backed by unique indexes"
      divider(longest_model_length * 2)

      column_1_header, column_2_header = column_headers(macro)
      print column_1_header.ljust(longest_model_length + 2)
      puts column_2_header

      divider(longest_model_length * 2)
    end

    def report_missing_index_for_validates_uniqueness_of(index, first_column_width)
      print index.table_name.ljust(first_column_width + 2)
      puts "(#{index.columns.join(", ")})"
    end

    def report_validates_uniqueness_problems(indexes_by_model)
      if indexes_by_model.empty?
        report_success(:validates_uniqueness_of)
      else
        indexes_by_table_name = indexes_by_model.map do |model, indexes|
          [model.table_name, indexes]
        end.sort_by(&:first)
        longest_model_length = indexes_by_table_name.map(&:first).
                                                     sort_by(&:length).
                                                     last.
                                                     length
        column_1_header = column_headers(:validates_uniqueness_of).first.length
        longest_model_length = [longest_model_length, ].max

        report_failure_header(:validates_uniqueness_of, longest_model_length)

        indexes_by_table_name.each do |table, indexes|
          indexes.each do |index|
            report_missing_index_for_validates_uniqueness_of(index, longest_model_length)
          end
        end
        divider(longest_model_length * 2)
      end
      puts
    end

    def divider(pad_to = TERMINAL_WIDTH)
      puts "-" * [pad_to, TERMINAL_WIDTH].max
    end
  end
end
