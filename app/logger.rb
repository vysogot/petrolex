# frozen_string_literal: true

module Petrolex
  # Outputs logs
  class Logger
    JUSTIFY_UP_TO = 6
    FILL_UP_CHAR = '0'
    COLORS = { red: 31, green: 32, yellow: 33, none: 0 }.freeze

    def initialize(timer:, silent:, color: :none)
      @timer = timer
      @silent = silent
      @color = color
    end

    def info(message)
      return if silent

      puts colorize("#{current_tick}: #{message}")
    end

    def print(message)
      return if silent

      puts colorize(message)
    end

    private

    attr_reader :silent, :timer, :color

    def colorize(message)
      "\e[#{COLORS[color.to_sym]}m#{message}\e[0m"
    end

    def current_tick
      timer.current_tick.to_s.rjust(JUSTIFY_UP_TO, FILL_UP_CHAR)
    end
  end
end
