# frozen_string_literal: true

module Petrolex
  # Runs a simulation
  class Runner
    def initialize(simulations:, ascii_art:)
      @simulations = simulations
      @ascii_art = ascii_art
    end

    def call
      Async do |task|
        simulations.each do |simulation|
          task.async { AsciiArt.new(simulation:).call } if ascii_art
          task.async { simulation.run }
        end
      end
    end

    private

    attr_reader :simulations, :ascii_art
  end
end
