# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    Error = Class.new(StandardError)
    AlreadyClosed = Class.new(Error)
    NotEnoughFuel = Class.new(Error)

    attr_accessor :fuel_reserve, :is_occupied, :is_open
    attr_reader :fueling_speed, :dispenser

    def initialize(fuel_reserve:, dispenser:)
      @fuel_reserve = fuel_reserve
      @fueling_speed = fueling_speed
      @dispenser = mount(dispenser)
      @lock = Mutex.new
    end

    def open
      self.is_open = true
      log_station_opens
    end

    def close
      self.is_open = false
      log_station_closes
    end

    def closed?
      !open?
    end

    def request_fueling(car)
      return unless can_fuel?(car)

      handle_fueling(car)
    end

    def waiting_times
      dispenser.waiting_times
    end

    def fueling_times
      dispenser.fueling_times
    end

    private

    def mount(dispenser)
      dispenser.tap do |d|
        d.station = self
      end
    end

    def can_fuel?(car)
      raise AlreadyClosed unless open?
      raise NotEnoughFuel unless enough_fuel?(car.litres_to_fuel)

      available?
    end

    def open?
      is_open
    end

    def occupied?
      !available?
    end

    def available?
      dispenser.available?
    end

    def enough_fuel?(litres)
      fuel_reserve >= litres
    end

    def handle_fueling(car)
      dispenser.fuel(car)
      subtract_fuel(car.litres_to_fuel)
    end

    def subtract_fuel(litres)
      self.fuel_reserve -= litres
    end

    def log_station_opens
      Logger.info('Station opens. Awaiting cars.')
    end

    def log_station_closes
      Logger.info("Station closes. #{last_client_info}Goodbye!")
    end

    def last_client_info
      'Finishing last client! ' if occupied?
    end
  end
end
