require 'consistency_fail/models'
require 'consistency_fail/introspectors/table_data'
require 'consistency_fail/introspectors/validates_uniqueness_of'
require 'consistency_fail/introspectors/has_one'
require 'consistency_fail/introspectors/polymorphic'
require 'consistency_fail/reporter'

module ConsistencyFail
  def self.run
    models = ConsistencyFail::Models.new($LOAD_PATH)
    models.preload_all

    reporter = ConsistencyFail::Reporter.new

    success = true

    introspector = ConsistencyFail::Introspectors::ValidatesUniquenessOf.new
    problems = problems(models.all, introspector)
    reporter.report_validates_uniqueness_problems(problems)
    success &&= problems.empty?

    introspector = ConsistencyFail::Introspectors::HasOne.new
    problems = problems(models.all, introspector)
    reporter.report_has_one_problems(problems)
    success &&= problems.empty?

    introspector = ConsistencyFail::Introspectors::Polymorphic.new
    problems = problems(models.all, introspector)
    reporter.report_polymorphic_problems(problems)
    success &&= problems.empty?
    
    success
  end
  
  private
  
  def self.problems(models, introspector)
    models.map do |m|
      [m, introspector.missing_indexes(m)]
    end.reject do |m, indexes|
      indexes.empty?
    end
  end
end