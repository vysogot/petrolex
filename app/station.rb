# frozen_string_literal: true

# Sells fuel
class Station
  attr_accessor :fuel_reserve, :is_occupied, :is_open

  def initialize(fuel_reserve: 30_000, is_occupied: false, fueling_speed: 0.5, is_open: true)
    @fuel_reserve = fuel_reserve
    @is_occupied = is_occupied
    @fueling_speed = fueling_speed
    @is_open = is_open
  end

  def request_fueling(car, litres)
    return false unless can_fuel?(litres)

    handle_fueling(car, litres)
    true
  end

  def open
    @is_open = true
    log_station_opens
  end

  private

  def can_fuel?(litres)
    is_open && !is_occupied && enough_fuel?(litres)
  end

  def enough_fuel?(litres)
    fuel_reserve - litres >= 0
  end

  def handle_fueling(car, litres)
    @is_occupied = true
    fuel(car, litres)
    @is_occupied = false
  end

  def fuel(car, litres)
    log_fueling_starts(car.id, litres, car.time_waited)

    fueling_time = litres * @fueling_speed
    Timer.instance.wait(fueling_time)
    @fuel_reserve -= litres
    car.tank_level = car.tank_volume

    log_fueling_ends(car.id, litres, fueling_time)
  end

  def log_fueling_starts(car_id, litres, fueling_time)
    Logger.info("Car##{car_id} waited #{fueling_time} seconds to fuel")
    Logger.info("Car##{car_id} starts fueling #{litres} litres")
  end

  def log_fueling_ends(car_id, litres, fueling_time)
    Logger.info("Tanked #{litres} liters of Car#" \
                "#{car_id} in #{fueling_time} seconds")
  end

  def log_station_opens
    Logger.info('Station opens. Awaiting cars.')
  end
end
