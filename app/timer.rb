# frozen_string_literal: true

module Petrolex
  # Syncs simulation time
  class Timer
    STARTING_TICK = 0

    attr_reader :current_tick, :speed

    def initialize(speed: 1000, tick_step: 1)
      @current_tick = STARTING_TICK
      @tick_step = tick_step
      @speed = speed
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
      1.0 / speed
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

    def pause_for(ticks)
      pause_until(current_tick + ticks)
    end

    def pause_until(given_tick)
      loop do
        break if over?(given_tick)

        wait
      end
    end

    private

    attr_accessor :timer_thread, :tick_step
    attr_writer :current_tick

    def tick
      self.current_tick += tick_step
    end
  end
end
