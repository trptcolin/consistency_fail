require 'consistency_fail/reporters/base'

module ConsistencyFail
  module Reporters
    class Polymorphic < Base
      attr_reader :macro

      def initialize
        @macro = :has_one_with_polymorphic
      end
    end
  end
end
