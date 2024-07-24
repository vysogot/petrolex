# frozen_string_literal: true

module Petrolex
  # Pours petrol to a car
  class Pump
    UNIT = 1

    attr_accessor :id, :station, :is_busy
    attr_reader :units, :speed

    def initialize(speed:)
      @speed = speed
      @is_busy = false
    end

    def busy? = is_busy

    def fuel(car)
      self.is_busy = true
      Logger.info("#{id} pumping #{car}")

      before = Timer.instance.current_tick
      units_wanted = car.want.dup
      units_given = 0
      status = nil

      begin
        units_wanted.times do
          station.take_fuel(UNIT)
          car.fuel(UNIT)
          units_given += 1
          Timer.instance.pause_for(speed)
        end
      rescue Station::NoMoreFuel => e
        Logger.info("#{id} can't pump #{units_wanted} into #{car} as there is not enough fuel")
        status = units_given.positive? ? :partial : :none
      else
        status = :full
      ensure
        after = Timer.instance.current_tick
        fueling_time = after - before
        last_servings = station.open? ? '' : 'After close servings: '
        Logger.info("#{last_servings}#{id} pumped #{units_given} litres of fuel into #{car} in #{fueling_time} seconds")
        self.is_busy = false
      end

      { status:, fueling_time:, units_wanted:, units_given: }
    end
  end
end
