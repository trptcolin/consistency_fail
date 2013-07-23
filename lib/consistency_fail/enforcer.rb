require 'consistency_fail'

module ConsistencyFail
  class Enforcer
    def problems(models, introspector)
      problems = models.map do |m|
        [m, introspector.missing_indexes(m)]
      end.reject do |m, indexes|
        indexes.empty?
      end
    end

    def self.enforce!
      models = ConsistencyFail::Models.new($LOAD_PATH)
      models.preload_all

      introspectors = [ConsistencyFail::Introspectors::ValidatesUniquenessOf.new,
                       ConsistencyFail::Introspectors::HasOne.new,
                       ConsistencyFail::Introspectors::Polymorphic.new]

      problem_models_exist = models.all.detect do |model|
        introspectors.any? {|i| !i.missing_indexes(model).empty?}
      end

      if problem_models_exist
        mega_fail!
      end
    end

    def self.mega_fail!
      ActiveRecord::Base.class_eval do
        class << self
          def panic
            raise "You've got missing indexes! Run `consistency_fail` to find and fix them."
          end

          def find(*arguments)
            panic
          end

          alias :first :find
          alias :last :find
          alias :count :find
        end

        def save(*arguments)
          self.class.panic
        end

        def save!(*arguments)
          self.class.panic
        end
      end
    end

  end
end
