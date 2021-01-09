# frozen_string_literal: true

# Outputs logs
class Logger
  def self.info(message)
    current_tick = Timer.instance.current_tick.to_s.rjust(5, '0')
    puts("#{current_tick}: #{message}")
  end
end
