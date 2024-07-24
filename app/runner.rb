# frozen_string_literal: true

module Petrolex
  # Runs a simulation
  class Runner
    def call(simulation:)
      start_time = Time.now

      puts simulation.intro
      simulation.run
      puts simulation.outro

      finish_time = Time.now

      puts "Runner took #{finish_time - start_time} seconds"
    end
  end
end
