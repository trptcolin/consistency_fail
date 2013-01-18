module ConsistencyFail
  class Index
    attr_reader :model, :table_name, :columns
    def initialize(model, table_name, columns)
      @model = model
      @table_name = table_name
      @columns = columns.map(&:to_s)
    end

    def ==(other)
      self.table_name == other.table_name &&
        self.columns.sort == other.columns.sort
    end
  end
end
