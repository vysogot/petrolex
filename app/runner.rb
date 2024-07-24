# frozen_string_literal: true

module Petrolex
  # Runs a simulation
  class Runner
    def call
      start_time = Time.now

      Timer.configure do |timer|
        timer.speed = 10_000
        timer.tick_step = 1
      end

      simulation = Simulation.new

      puts simulation.intro

      Timer.instance.start
      simulation.threads.each(&:join)
      Timer.instance.stop

      puts simulation.report

      finish_time = Time.now

      puts "Simulation took #{finish_time - start_time} seconds"
    end
  end
end
