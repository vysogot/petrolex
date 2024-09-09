# frozen_string_literal: true

module Petrolex
  # Provides fueling service
  class Station
    NoMoreFuel = Class.new(StandardError)

    attr_reader :mounted_pumps, :reserve, :name, :timer, :logger, :fuel_price, :fuel_cost, :pumps,
      :pump_base_cost, :report
    attr_accessor :is_open

    def initialize(simulation:, name:, reserve:, pumps:, fuel_price:, fuel_cost:, pump_base_cost:)
      @reserve_lock = Mutex.new

      @timer = simulation.timer
      @logger = simulation.logger
      @report = simulation.report

      @name = name
      @reserve = reserve
      @pumps = pumps
      @fuel_price = fuel_price
      @fuel_cost = fuel_cost
      @pump_base_cost = pump_base_cost

      @is_open = false
      @mounted_pumps = []

      mount_pumps
      report_initial_costs
    end

    def to_s = name

    def open
      self.is_open = true
      logger.info('Station opens')
    end

    def open? = is_open
    def closed? = !open?

    def close
      self.is_open = false
      message = done? ? '' : '... finishing cars being pumped'
      logger.info("Station closes#{message}")
    end

    def done?
      closed? && mounted_pumps.none?(&:busy?)
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

    def avg_pumps_speed
      mounted_pumps.sum(&:speed) / mounted_pumps.size
    end

    private

    def mount_pumps
      pumps.each { |pump| mount_pump(pump) }
    end

    def mount_pump(pump)
      pump.id = "Pump#{mounted_pumps.size.succ}"
      pump.station = self

      mounted_pumps << pump
    end

    def report_initial_costs
      initial_fuel_cost = fuel_cost * reserve
      initial_pumps_cost = pumps.sum { |pump| 1.0/pump.speed * pump_base_cost }

      report.for(station_name: name).update_costs(initial_fuel_cost:, initial_pumps_cost:)
      report.for(station_name: name).update_reserve(count: reserve)
    end

    attr_reader :reserve_lock
    attr_writer :reserve
  end
end
