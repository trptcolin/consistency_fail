module ConsistencyFail
  class Reporter
    TERMINAL_WIDTH = 80

    def report_has_one_problems(indexes_by_model)
      if indexes_by_model.empty?
        divider
        puts "Hooray! All has_one calls are correctly backed by a unique index."
        divider
      else
        indexes_by_table_name = indexes_by_model.map do |model, indexes|
          ["#{model.name}", indexes]
        end.sort_by(&:first)
        model_header = "Offending Model"
        longest_model_length = indexes_by_table_name.map(&:first).
                                                     sort_by(&:length).
                                                     last.
                                                     length
        longest_model_length = [longest_model_length, model_header.length].max

        puts
        divider(longest_model_length * 2)
        puts "has_one calls not backed by unique indexes"
        divider(longest_model_length * 2)
        print model_header.ljust(longest_model_length + 2)
        puts "Desired Unique Index (order is irrelevant)"
        divider(longest_model_length * 2)

        indexes_by_table_name.each do |table, indexes|
          indexes.each do |index|
            print table.ljust(longest_model_length + 2)
            print "#{index.table_name}: "
            puts "(#{index.columns.join(", ")})"
          end
        end
        divider(longest_model_length * 2)
      end
      puts
    end

    def report_validates_uniqueness_problems(indexes_by_model)
      if indexes_by_model.empty?
        divider
        puts "Hooray! All validates_uniqueness calls are correctly backed by a unique index."
        divider
      else
        indexes_by_table_name = indexes_by_model.map do |model, indexes|
          [model.table_name, indexes]
        end.sort_by(&:first)
        table_header = "Table"
        longest_model_length = indexes_by_table_name.map(&:first).
                                                     sort_by(&:length).
                                                     last.
                                                     length
        longest_model_length = [longest_model_length, table_header.length].max

        puts
        divider(longest_model_length * 2)
        puts "validates_uniqueness calls not backed by unique indexes"
        divider(longest_model_length * 2)
        print table_header.ljust(longest_model_length + 2)
        puts "Columns (multicolumn order is alphabetical)"
        divider(longest_model_length * 2)

        indexes_by_table_name.each do |table, indexes|
          indexes.each do |index|
            print table.ljust(longest_model_length + 2)
            puts "(#{index.columns.join(", ")})"
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
