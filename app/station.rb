# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    NoMoreFuel = Class.new(StandardError)

    attr_reader :mounted_pumps, :reserve
    attr_accessor :is_open

    def initialize(reserve:, pumps:)
      @reserve = reserve
      @reserve_lock = Mutex.new
      @is_open = false
      @mounted_pumps = []

      pumps.each { |pump| mount_pump(pump) }
    end

    def open
      self.is_open = true
      Logger.info('Station opens')
    end

    def open? = is_open

    def close
      self.is_open = false
      message = done? ? '' : '... finishing cars being pumped'
      Logger.info("Station closes#{message}")
    end

    def done?
      !open? && mounted_pumps.none?(&:busy?)
    end

    def mount_pump(pump)
      pump.id = "Pump#{mounted_pumps.size.succ}"
      pump.station = self

      mounted_pumps << pump
    end

    def take_fuel(units)
      reserve_lock.synchronize do
        after = reserve - units
        raise NoMoreFuel if after.negative?

        self.reserve = after
      end
    end

    def reserve_reading
      reserve_lock.synchronize { reserve }
    end

    private

    attr_reader :reserve_lock
    attr_writer :reserve
  end
end
