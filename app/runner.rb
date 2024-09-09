# frozen_string_literal: true

module Petrolex
  class Runner
    def initialize(simulations:, ascii_art:)
      @simulations = simulations
      @ascii_art = ascii_art
    end

    def call
      Async do |task|
        task.async { first_two_simulations.call } if ascii_art?

        simulations.each do |simulation|
          task.async { simulation.run }
        end
      end
    end

    private

    def first_two_simulations
      AsciiArt.new(simulations: simulations.take(2))
    end

    def ascii_art?
      ascii_art
    end

    attr_reader :simulations, :ascii_art
  end
end
