# frozen_string_literal: true

# Sells fuel
class Station
  attr_accessor :fuel_reserve, :is_occupied, :is_open
  attr_reader :fueling_speed, :queue, :waiting_times

  def initialize(fuel_reserve:, fueling_speed:)
    @fuel_reserve = fuel_reserve
    @fueling_speed = fueling_speed
    @waiting_times = []
    @queue = []
  end

  def request_fueling(car)
    return false unless can_fuel?(car.litres_to_fuel)

    handle_fueling(car)
    true
  end

  def open
    self.is_occupied = false
    self.is_open = true
    log_station_opens
  end

  def close
    self.is_open = false
    log_station_closes
  end

  def closed?
    !is_open
  end

  private

  def can_fuel?(litres)
    is_open && !is_occupied && enough_fuel?(litres)
  end

  def enough_fuel?(litres)
    fuel_reserve - litres >= 0
  end

  def subtract_fuel(litres)
    self.fuel_reserve -= litres
  end

  def handle_fueling(car)
    self.is_occupied = true
    fuel(car)
    self.is_occupied = false
  end

  def fuel(car)
    waiting_time = Timer.instance.current_tick - car.entry_tick
    log_fueling_starts(car.id, car.litres_to_fuel, waiting_time)

    fueling_time = car.litres_to_fuel / fueling_speed
    Timer.instance.pause_until(car.entry_tick + waiting_time + fueling_time)
    subtract_fuel(car.litres_to_fuel)
    car.tank_level = car.tank_volume

    log_fueling_ends(car.id, car.litres_to_fuel, fueling_time)
    waiting_times << waiting_time
  end

  def log_fueling_starts(car_id, litres, waiting_time)
    Logger.info("Car##{car_id} waited #{waiting_time} seconds to fuel")
    Logger.info("Car##{car_id} starts fueling #{litres} litres")
  end

  def log_fueling_ends(car_id, litres, fueling_time)
    Logger.info("Tanked #{litres} liters of Car##{car_id} in #{fueling_time} seconds")
  end

  def log_station_opens
    Logger.info('Station opens. Awaiting cars.')
  end

  def log_station_closes
    Logger.info('Station closes. Goodbye!')
  end
end
