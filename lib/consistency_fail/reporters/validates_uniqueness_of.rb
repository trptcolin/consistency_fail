require 'consistency_fail/reporters/base'

module ConsistencyFail
  module Reporters
    class ValidatesUniquenessOf < Base
      attr_reader :macro

      def initialize
        @macro = :validates_uniqueness_of
      end
    end
  end
end
