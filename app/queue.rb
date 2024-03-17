# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :line, :unserved, :fueled

    def initialize(station:)
      @station = station
      @line = []
      @unserved = []
      @fueled = []
    end

    def push(car)
      line << car
      car.entry_tick = Timer.instance.current_tick

      Logger.info("Car##{car.id} has arrived and is #{line.size} in queue")
    end

    def consume
      return unless (car = first_in_line)
      station.request_fueling(car)
      fueled << car
    rescue Station::NotEnoughFuel
      unserved << car
      Logger.info("Car##{car.id} needed #{car.litres_to_fuel} litres and has left due to lack of fuel")
    end

    private

    def first_in_line
      line.shift
    end
  end
end
