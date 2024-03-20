# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :waiting, :unserved, :fueled

    def initialize(station:)
      @station = station
      @waiting = []
      @unserved = []
      @fueled = []
    end

    def push(car)
      waiting << car
      car.entry_tick = Timer.instance.current_tick

      Logger.info("#{car.plate} has arrived and is #{waiting.size} in queue")
    end

    def consume
      return unless (car = first_in_waiting)

      station.request_fueling(car)
      fueled << car
    rescue Station::AlreadyClosed
      handle_unserved(car, "#{car.plate} left as the station is closed")
    rescue Station::NotEnoughFuel
      handle_unserved(car, "#{car.plate} needed #{car.litres_to_fuel} litres and has left due to lack of fuel")
    end

    private

    def first_in_waiting
      waiting.shift
    end

    def handle_unserved(car, message)
      unserved << car
      Logger.info(message)
    end
  end
end
