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

    def fuel
      self.level += want
    end

    def want
      @want ||= volume - level
    end

    private

    attr_reader :volume
    attr_writer :level
  end
end
