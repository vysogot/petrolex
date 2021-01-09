class Timer
  attr_accessor :simulation_speed

  def initialize(simulation_speed)
    @simulation_speed = simulation_speed
  end

  def self.setup(simulation_speed: 1)
    @@instance ||= self.new(simulation_speed)
    @@tick = 0
  end

  def self.instance
    @@instance
  end

  def start
    tick_step = 1

    Thread.new do |t|
      loop do
        @@instance.wait(tick_step)
        @@tick += tick_step
      end
    end
  end

  def self.current_tick
    @@tick
  end

  def wait(seconds)
    sleep(seconds/@@instance.simulation_speed.to_f)
  end
end
