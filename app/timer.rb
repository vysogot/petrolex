# frozen_string_literal: true

module Petrolex
  # Syncs simulation time
  class Timer
    attr_accessor :tick_step, :simulation_speed
    attr_reader :current_tick

    def initialize
      @current_tick = 0
      @tick_step = 1
      @simulation_speed = 1
    end

    @instance = new

    def self.instance
      @instance
    end

    def self.configure
      yield(instance)
    end

    def start
      self.timer_thread = Thread.new do
        loop do
          wait
          tick
        end
      end
    end

    def stop
      timer_thread.terminate
    end

    def tick_duration
      1.0 / simulation_speed
    end

    def wait
      sleep(tick_duration)
    end

    def over?(given_tick)
      current_tick >= given_tick
    end

    def ticks_from(given_tick)
      current_tick - given_tick
    end

    def pause_until(given_tick)
      loop do
        break if over?(given_tick)
        wait
      end
    end

    private

    attr_accessor :timer_thread
    attr_writer :current_tick

    def instance
      self.class.instance
    end

    def tick
      self.current_tick += tick_step
    end
  end
end
