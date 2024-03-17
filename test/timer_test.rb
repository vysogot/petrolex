# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  class TimerTest < Minitest::Test
    def test_it_ticks
      Timer.instance.start

      sleep(1 / 10.0)

      assert Timer.instance.current_tick.positive?
    end
  end
end
