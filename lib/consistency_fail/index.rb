module ConsistencyFail
  class Index
    attr_reader :table_name, :columns
    def initialize(table_name, columns)
      @table_name = table_name
      @columns = columns.map(&:to_s).sort
    end

    def ==(other)
      self.table_name == other.table_name && self.columns == other.columns
    end
  end
end
