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
        next column unless names.include?(column)
        reflection = @model.reflect_on_association(column.to_sym)
        if reflection.options[:polymorphic]
          [reflection.foreign_key, reflection.foreign_type]
        else
          reflection.foreign_key
        end
      end
      @columns.flatten!
    end
  end
end
