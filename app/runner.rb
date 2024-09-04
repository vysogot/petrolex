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
        task.async { AsciiArt.new(simulations: simulations.take(2)).call } if ascii_art?

        simulations.each do |simulation|
          task.async { simulation.run }
        end
      end
    end

    private

    def ascii_art?
      ascii_art
    end

    attr_reader :simulations, :ascii_art
  end
end
