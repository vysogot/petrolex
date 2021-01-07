class Station
  attr_accessor :fuel_reserve, :is_occupied

  def initialize(fuel_reserve: 30_000, is_occupied: false)
    @fuel_reserve = fuel_reserve
    @is_occupied = is_occupied
  end

  def request_fueling(car, litres)
    return false unless can_fuel?(litres)
    handle_fueling(car, litres)
    true
  end

  private

  def can_fuel?(litres)
    enough_fuel?(litres) && !is_occupied
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
    log_start(car.id, litres, car.seconds_waited)

    seconds_to_fuel = (litres * rand(0.5..0.7)).round(3)
    TimeService.wait(seconds_to_fuel/100)
    @fuel_reserve -= litres
    car.tank_level = car.tank_volume

    log_end(car.id, litres, seconds_to_fuel)
  end

  def log_start(car_id, litres, seconds_waited)
    Logger.info("Car##{car_id} waited #{seconds_waited} seconds to fuel")
    Logger.info("Car##{car_id} starts fueling #{litres} litres")
  end

  def log_end(car_id, litres, seconds)
    Logger.info("Tanked #{litres} liters of Car#" +
                "#{car_id} in #{seconds} seconds\n\n")
  end
end

class Car
  attr_accessor :tank_volume, :tank_level, :id, :seconds_waited

  def initialize(tank_volume: 70, tank_level: 10)
    @tank_volume = tank_volume
    @tank_level = tank_level
    @id = rand(1..10_000)
    @seconds_waited = 0
  end

  def try_to_fuel(station)
    if station.request_fueling(self, litres_to_fuel) == false
      wait
      try_to_fuel(station)
    end
  end

  private

  def litres_to_fuel
    tank_volume - tank_level
  end

  def wait
    seconds_to_wait = 1
    TimeService.wait(seconds_to_wait)
    @seconds_waited += seconds_to_wait
  end
end

class TimeService
  def self.wait(seconds)
    sleep(seconds)
  end
end

class Logger
  def self.info(message)
    puts(message)
  end
end
