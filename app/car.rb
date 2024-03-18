# frozen_string_literal: true

module Petrolex
  # Fuels at the Station
  class Car
    attr_accessor :entry_tick
    attr_reader :plate

    def initialize(plate:, tank_volume:, tank_level:)
      @plate = plate
      @tank_volume = tank_volume
      @tank_level = tank_level
    end

    def fuel(litres)
      self.tank_volume += litres
    end

    def litres_to_fuel
      @litres_to_fuel ||= tank_volume - tank_level
    end

    private

    attr_accessor :tank_volume
    attr_reader :tank_level
  end
end
