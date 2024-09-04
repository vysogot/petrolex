# frozen_string_literal: true

module Petrolex
  # Pours petrol to a car
  class Pump
    UNIT = 1

    attr_accessor :id, :station, :is_busy, :car
    attr_reader :speed

    def initialize(speed:)
      @speed = speed
      @is_busy = false
    end

    def busy? = is_busy

    def fuel(car)
      prepare_for_fueling(car)

      start = timer.current_tick
      units_wanted = car.want.dup
      units_given = perform_fueling(car, units_wanted)
      status = determine_status(units_given, units_wanted)

      finish = timer.current_tick
      fueling_time = finish - start

      finalize_fueling(car, units_given, fueling_time)

      { status:, car:, fueling_time:, units_wanted:, units_given: }
    end

    private

    def timer = station.timer
    def logger = station.logger

    def prepare_for_fueling(car)
      self.is_busy = true
      self.car = car
      logger.info("#{id} pumping #{car}")
    end

    def perform_fueling(car, units_wanted)
      units_given = 0

      begin
        units_wanted.times do
          station.take_fuel(UNIT)
          car.fuel(UNIT)
          units_given += UNIT
          timer.pause_for(speed)
        end
      rescue Station::NoMoreFuel
        logger.info("#{id} can't pump #{units_wanted} into #{car} as there is not enough fuel")
      end

      units_given
    end

    def determine_status(units_given, units_wanted)
      return :none if units_given.zero?

      units_given == units_wanted ? :full : :partial
    end

    def finalize_fueling(car, units_given, fueling_time)
      last_servings = station.open? ? '' : 'After close servings: '
      logger.info("#{last_servings}#{id} pumped #{units_given} litres " \
        "of fuel into #{car} in #{fueling_time} seconds")
      self.is_busy = false
      self.car = nil
    end
  end
end
