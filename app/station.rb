# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    Error = Class.new(StandardError)
    AlreadyClosed = Class.new(Error)
    NotEnoughFuel = Class.new(Error)

    attr_accessor :fuel_reserve, :is_occupied, :is_open
    attr_reader :fueling_speed, :dispensers

    def initialize(fuel_reserve:, dispensers:)
      @fuel_reserve = fuel_reserve
      @fueling_speed = fueling_speed
      @dispensers = mount(dispensers)
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
      dispensers.map(&:waiting_times).flatten
    end

    def fueling_times
      dispensers.map(&:fueling_times).flatten
    end

    private

    def mount(dispensers)
      dispensers.tap do |ds|
        ds.each { |d| d.station = self }
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
      !first_available_dispenser.nil?
    end

    def first_available_dispenser
      dispensers.detect(&:available?)
    end

    def enough_fuel?(litres)
      fuel_reserve >= litres
    end

    def handle_fueling(car)
      first_available_dispenser.fuel(car)
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
