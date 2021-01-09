class Timer
  attr_accessor :simulation_speed

  def initialize(simulation_speed: 1)
    @simulation_speed = simulation_speed
  end

  def self.setup(simulation_speed: 1)
    @@instance ||= self.new(simulation_speed: simulation_speed)
  end

  def self.instance
    @@instance
  end

  def wait(seconds)
    sleep(seconds/@@instance.simulation_speed.to_f)
  end
end
