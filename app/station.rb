# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    NoMoreFuel = Class.new(StandardError)

    attr_reader :pumps, :reserve
    attr_accessor :is_open

    def initialize(reserve:)
      @reserve = reserve
      @reserve_lock = Mutex.new
      @is_open = false
      @pumps = []
    end

    def open
      self.is_open = true
      Logger.info('Station opens')
    end

    def open? = is_open

    def close
      self.is_open = false
      Logger.info('Station closes')
    end

    def add_pump(pump)
      pump.id = "Pump#{pumps.size.succ}"
      pump.station = self

      pumps << pump
    end

    def take_fuel(units)
      reserve_lock.synchronize do
        after = self.reserve - units
        raise NoMoreFuel if after < 0

        self.reserve = after
      end
    end

    private

    attr_reader :reserve_lock
    attr_writer :reserve
  end
end
