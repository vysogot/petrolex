# frozen_string_literal: true

module Petrolex
  # Runs a simulation
  class Runner
    def call
      Timer.configure do |timer|
        timer.speed = 1000
        timer.tick_step = 1
      end

      simulation = Simulation.new
      simulation.configure do |simulation|
        simulation.cars_number = 20
      end

      puts simulation.intro

      Timer.instance.start
      simulation.threads.each(&:join)
      Timer.instance.stop

      puts simulation.report
    end
  end
end
