require 'consistency_fail/index'

module ConsistencyFail
  module Introspectors
    class HasOne

    def instances(model)
      model.reflect_on_all_associations.select do |a|
        a.macro == :has_one
      end
    end

#    # TODO: handle has_one :through cases (multicolumn index on the join table?)
#    def desired_indexes_for_has_one_on(model)
#      has_one_calls_on(model).map do |v|
#        ConsistencyFail::Index.new(v.table_name, [v.primary_key_name]) rescue nil
#      end.compact
#    end
#    private :desired_indexes_for_has_one_on
#
#    def missing_indexes_for_has_one_on(model)
#      existing_indexes = unique_indexes_on(model)
#
#      desired_indexes_for_has_one_on(model).reject do |index|
#        existing_indexes.include?(index)
#      end
#    end

    end
  end
end
