# frozen_string_literal: true

module Petrolex
  # Outputs logs
  class Logger
    JUSTIFY_UP_TO = 6
    FILL_UP_CHAR = '0'
    COLORS = { red: 31, green: 32, yellow: 33, none: 0 }

    def initialize(timer:, silent:, color: :none)
      @timer = timer
      @silent = silent
      @color = color
      @lock = Mutex.new
    end

    def info(message)
      return if silent

      lock.synchronize do
        puts colorize("#{current_tick}: #{message}")
      end
    end

    def print(message)
      puts colorize(message)
    end

    private

    attr_reader :lock, :silent, :timer, :color

    def colorize(message)
      "\e[#{COLORS[color]}m#{message}\e[0m"
    end

    def current_tick
      timer.current_tick.to_s.rjust(JUSTIFY_UP_TO, FILL_UP_CHAR)
    end
  end
end
