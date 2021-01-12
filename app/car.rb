# frozen_string_literal: true

# Fuels at the Station
class Car
  attr_accessor :tank_volume, :tank_level, :id,
                :time_waited, :retry_fueling, :keep_trying,
                :in_queue, :entry_tick

  def initialize(tank_volume: 70,
                 tank_level: 10,
                 retry_fueling: true)
    @tank_volume = tank_volume
    @tank_level = tank_level
    @id = rand(1..10_000)
    @time_to_wait = 1
    @time_waited = 0
    @keep_trying = true
    @in_queue = false
    @retry_fueling = retry_fueling
  end

  def queue_up(station)
    @in_queue = station.enqueue(self)
    @entry_tick = Timer.instance.current_tick
    Logger.info("Car##{id} has arrived and " \
                "is #{in_queue} in queue")
  end

  def try_to_fuel(station)
    station.request_fueling(self, litres_to_fuel)
  end

  private

  def litres_to_fuel
    tank_volume - tank_level
  end
end
