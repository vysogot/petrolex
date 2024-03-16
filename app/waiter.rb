# frozen_string_literal: true

# Waits for the right tick
class Waiter
  def self.call(tick)
    loop do
      break if Timer.instance.current_tick >= tick
      sleep(0.001)
    end
  end
end
