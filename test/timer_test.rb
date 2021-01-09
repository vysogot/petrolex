require_relative 'test_helper'

class TimerTest < Minitest::Test
  def test_it_ticks
    Timer.instance.start

    sleep(1/10.0)

    assert Timer.current_tick > 0
  end
end
