# frozen_string_literal: true

module Petrolex
  # Outputs logs
  class Logger
    JUSTIFY_UP_TO = 6
    FILL_UP_CHAR = '0'

    attr_reader :lock

    def initialize
      @lock = Mutex.new
    end

    @instance = new

    class << self
      extend Forwardable
      attr_reader :instance

      def_delegators :instance, :info
    end

    def info(message)
      lock.synchronize do
        puts "#{current_tick}: #{message}"
      end
    end

    private

    def current_tick
      Timer.instance.current_tick.to_s.rjust(JUSTIFY_UP_TO, FILL_UP_CHAR)
    end
  end
end
