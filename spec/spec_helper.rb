require 'bundler/setup'

Bundler.require(:default, :test)

require_relative 'support/active_record'
require_relative 'support/schema'
require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths << './spec/support/models'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
