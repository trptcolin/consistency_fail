begin
  require File.join(Dir.pwd, "config", "boot")
rescue LoadError => e
  puts "\nUh-oh! You must be in the root directory of a Rails project.\n"
  raise
end

require 'active_record'
require 'validation_reflection'
require File.join(Dir.pwd, "config", "environment")

require 'consistency_fail/engine'
require 'consistency_fail/introspectors/validates_uniqueness_of'
require 'consistency_fail/reporter'
