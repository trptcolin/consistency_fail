require 'active_record'

module ConsistencyFail
  class Engine
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

    MODEL_DIRECTORY_REGEXP = /models/

    def preload_all_models
      model_dirs = $LOAD_PATH.select do |lp|
        MODEL_DIRECTORY_REGEXP =~ lp
      end
      model_dirs.each do |d|
        Dir.glob(File.join(d, "**", "*.rb")).each do |model_filename|
          require_dependency model_filename
        end
      end
    end

    def models
      models = []
      ObjectSpace.each_object do |o|
        models << o if o.class == Class &&
                       o.ancestors.include?(ActiveRecord::Base) &&
                       o != ActiveRecord::Base
      end
      models.sort_by(&:name)
    end

    def uniqueness_validations_on(model)
      model.reflect_on_all_validations.select do |v|
        v.macro == :validates_uniqueness_of
      end
    end

    # TODO: test
    def has_one_calls_on(model)
      model.reflect_on_all_associations.select do |a|
        a.macro == :has_one
      end
    end

    def unique_indexes_on(model)
      return [] if !model.table_exists?

      ar_indexes = model.connection.indexes(model.table_name).select(&:unique)
      ar_indexes.map do |index|
        Index.new(model.table_name, index.columns)
      end
    end

    # TODO: test
    # TODO: handle has_one :through cases (multicolumn index on the join table?)
    def desired_indexes_for_has_one_on(model)
      has_one_calls_on(model).map do |v|
        Index.new(v.table_name, [v.primary_key_name]) rescue nil
      end.compact
    end
    private :desired_indexes_for_has_one_on

    def missing_indexes_for_has_one_on(model)
      existing_indexes = unique_indexes_on(model)

      desired_indexes_for_has_one_on(model).reject do |index|
        existing_indexes.include?(index)
      end
    end

    def desired_indexes_for_validates_uniqueness_of_on(model)
      uniqueness_validations_on(model).map do |v|
        scoped_columns = v.options[:scope] || []
        Index.new(model.table_name, [v.name, *scoped_columns])
      end
    end
    private :desired_indexes_for_validates_uniqueness_of_on

    def missing_indexes_for_validates_uniqueness_on(model)
      existing_indexes = unique_indexes_on(model)

      desired_indexes_for_validates_uniqueness_of_on(model).reject do |index|
        existing_indexes.include?(index)
      end
    end

  end
end
