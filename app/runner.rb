# frozen_string_literal: true

module Petrolex
  # Runs a simulation
  class Runner
    def call
      Timer.configure do |timer|
        timer.speed = 10000
        timer.tick_step = 1
      end

      simulation = Simulation.new

      puts simulation.intro

      Timer.instance.start
      simulation.threads.each(&:join)
      Timer.instance.stop

      puts simulation.report
      pp simulation.queue.report.sheet
    end
  end
end
