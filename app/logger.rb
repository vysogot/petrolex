# frozen_string_literal: true

module Petrolex
  # Outputs logs
  class Logger
    def self.info(message)
      current_tick = Timer.instance.current_tick.to_s.rjust(6, '0')
      puts("#{current_tick}: #{message}")
    end
  end
end
