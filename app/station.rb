# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    NoMoreFuel = Class.new(StandardError)

    attr_reader :mounted_pumps, :reserve, :name, :timer, :logger
    attr_accessor :is_open

    def initialize(timer:, logger:, name:, reserve:, pumps:)
      @timer = timer
      @logger = logger
      @name = name
      @reserve = reserve
      @reserve_lock = Mutex.new
      @is_open = false
      @mounted_pumps = []

      pumps.each { |pump| mount_pump(pump) }
    end

    def to_s = name

    def open
      self.is_open = true
      logger.info('Station opens')
    end

    def open? = is_open

    def close
      self.is_open = false
      message = done? ? '' : '... finishing cars being pumped'
      logger.info("Station closes#{message}")
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
