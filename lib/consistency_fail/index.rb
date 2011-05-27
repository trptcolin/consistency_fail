module ConsistencyFail
  class Index
    attr_reader :table_name, :columns
    def initialize(table_name, columns)
      @table_name = table_name
      @columns = columns.map(&:to_s)
    end

    def ==(other)
      self.table_name == other.table_name && self.columns.sort == other.columns.sort
    end
  end
end
