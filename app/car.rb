# frozen_string_literal: true

module Petrolex
  # Fuels at the Station
  class Car
    attr_accessor :entry_tick
    attr_reader :plate, :level

    def initialize(plate:, volume:, level:)
      @plate = plate
      @volume = volume
      @level = level
    end

    def fuel(units)
      self.level += units
    end

    def want
      volume - level
    end

    def to_s = plate

    private

    attr_reader :volume
    attr_writer :level
  end
end
