class Car
  attr_accessor :tank_volume, :tank_level, :id,
    :seconds_waited, :retry_fueling, :keep_trying,
    :simulation_speed

  def initialize(tank_volume: 70,
                 tank_level: 10,
                 retry_fueling: true,
                 simulation_speed: 1)
    @tank_volume = tank_volume
    @tank_level = tank_level
    @id = rand(1..10_000)
    @seconds_waited = 0
    @keep_trying = true
    @retry_fueling = retry_fueling
    @simulation_speed = simulation_speed
  end

  def try_to_fuel(station)
    Logger.info("Car##{id} has arrived")

    loop do
      if station.request_fueling(self, litres_to_fuel)
        @keep_trying = false
      end

      break unless keep_trying
      wait
    end
  end

  private

  def litres_to_fuel
    tank_volume - tank_level
  end

  def wait
    @keep_trying = retry_fueling
    seconds_to_wait = 1
    Timer.wait(seconds_to_wait/simulation_speed.to_f)
    @seconds_waited += seconds_to_wait
  end
end
