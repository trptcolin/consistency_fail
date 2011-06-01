require 'consistency_fail/reporters/base'

module ConsistencyFail
  module Reporters
    class HasOne < Base
      attr_reader :macro

      def initialize
        @macro = :has_one
      end
    end
  end
end
