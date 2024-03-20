# frozen_string_literal: true

module Petrolex
  # Pours petrol to a car
  class Dispenser
    attr_accessor :station, :car
    attr_reader :fueling_speed, :waiting_times, :fueling_times

    def initialize(fueling_speed:)
      @fueling_speed = fueling_speed
      @waiting_times = []
      @fueling_times = []
    end

    def available?
      car.nil?
    end

    def fuel(car)
      occupy(car) do
        log_fueling_starts
        execute
        log_fueling_ends
      end
    end

    private

    def occupy(car)
      self.car = car
      yield
      self.car = nil
    end

    def execute
      waiting_times << waiting_time
      Timer.instance.pause_until(car.entry_tick + waiting_time + fueling_time)
      car.fuel(car.litres_to_fuel)
      fueling_times << fueling_time
    end

    def waiting_time
      Timer.instance.ticks_from(car.entry_tick)
    end

    def fueling_time
      car.litres_to_fuel / fueling_speed
    end

    def log_fueling_starts
      Logger.info("#{car.plate} waited #{waiting_time} seconds to fuel")
      Logger.info("#{car.plate} starts fueling #{car.litres_to_fuel} litres")
    end

    def log_fueling_ends
      Logger.info("#{car.plate} got #{car.litres_to_fuel} liters in #{fueling_time} seconds")
    end
  end
end
