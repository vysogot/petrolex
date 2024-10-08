# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Logger do
    include SerialFaker

    it 'returns right message' do
      logger = Logger.new

      logger.stub :current_tick, 15 do
        output = catch_output do
          logger.info('hello')
        end

        assert_equal '000015: hello', output.chomp
      end
    end
  end
end
