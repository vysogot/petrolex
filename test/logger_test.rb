# frozen_string_literal: true

require_relative 'test_helper'

class LoggerTest < Minitest::Test
  include ::SerialFaker

  def test_info
    Timer.instance.stub :current_tick, 15 do
      output = catch_output do
        Logger.info('hello')
      end

      assert_equal '00015: hello', output.chomp
    end
  end
end
