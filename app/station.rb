# frozen_string_literal: true

# Sells fuel
class Station
  attr_accessor :fuel_reserve, :is_occupied, :is_open
  attr_reader :fueling_speed, :queue, :waiting_times, :closing_tick

  def initialize(fuel_reserve:, fueling_speed:, closing_tick:)
    @fuel_reserve = fuel_reserve
    @fueling_speed = fueling_speed
    @closing_tick = closing_tick
    @waiting_times = []
    @queue = []
  end

  def request_fueling(car, litres)
    return false unless can_fuel?(litres)

    handle_fueling(car, litres)
    true
  end

  def open
    self.is_occupied = false
    self.is_open = true
    log_station_opens
    queue_consumer.join
  end

  def close
    @is_open = false
    log_station_closes
  end

  def enqueue(car)
    @queue << car
    @queue.size
  end

  def consume_queue
    return unless (car = @queue.shift)

    car.try_to_fuel(self)
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
    waiting_time = Timer.instance.current_tick - car.entry_tick
    log_fueling_starts(car.id, litres, waiting_time)

    fueling_time = litres / fueling_speed
    Timer.instance.pause_until(car.entry_tick + waiting_time + fueling_time)
    @fuel_reserve -= litres
    car.tank_level = car.tank_volume

    log_fueling_ends(car.id, litres, fueling_time)
    @waiting_times << waiting_time
  end

  def queue_consumer
    ::QueueConsumer.new(station: self, closing_tick:).consumer
  end

  def log_fueling_starts(car_id, litres, waiting_time)
    Logger.info("Car##{car_id} waited #{waiting_time} seconds to fuel")
    Logger.info("Car##{car_id} starts fueling #{litres} litres")
  end

  def log_fueling_ends(car_id, litres, fueling_time)
    Logger.info("Tanked #{litres} liters of Car#" \
                "#{car_id} in #{fueling_time} seconds")
  end

  def log_station_opens
    Logger.info('Station opens. Awaiting cars.')
  end

  def log_station_closes
    Logger.info('Station closes. Goodbye!')
  end
end
