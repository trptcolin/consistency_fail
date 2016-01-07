module ConsistencyFail
  class Index
    attr_reader :model, :table_name, :columns
    def initialize(model, table_name, columns)
      @model = model
      @table_name = table_name
      @columns = columns.map(&:to_s)
      handle_associations
    end

    def ==(other)
      self.table_name == other.table_name &&
        self.columns.sort == other.columns.sort
    end

    private

    def handle_associations
      references = @model.reflect_on_all_associations(:belongs_to)
      names = references.map(&:name).map(&:to_s)
      @columns.map! do |column|
        if names.include?(column)
          @model.reflect_on_association(column.to_sym).foreign_key
        else
          column
        end
      end
    end
  end
end
