begin
  require File.join(Dir.pwd, "config", "boot")
rescue LoadError => e
  puts "\nUh-oh! You must be in the root directory of a Rails project.\n"
  raise
end

require 'active_record'
require 'validation_reflection'
require File.join(Dir.pwd, "config", "environment")

require 'consistency_fail/models'
require 'consistency_fail/introspectors/table_data'
require 'consistency_fail/introspectors/validates_uniqueness_of'
require 'consistency_fail/introspectors/has_one'
require 'consistency_fail/reporter'
