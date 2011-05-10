module ConsistencyFail
  class Reporter
    # TODO: get under test
    def report(indexes_by_model)
      if !indexes_by_model.empty?
        indexes_by_table_name = indexes_by_model.map{|model, columns| [model.table_name, columns]}
        puts "Oh noez! Found missing indexes!"
        longest_model_length = indexes_by_table_name.map(&:first).
                                                     sort_by(&:length).
                                                     last.
                                                     length
        puts "=" * 70

        indexes_by_table_name.sort_by{|table, columns| table}.each do |table, columns|
          columns.each do |column_group|
            puts "#{table.ljust(longest_model_length + 1)} #{column_group.inspect}"
          end
        end
      end
    end
  end
end
