# frozen_string_literal: true

# Fuels at the Station
class Car
  attr_accessor :id, :tank_volume, :tank_level, :entry_tick

  def initialize(tank_volume:, tank_level:)
    @id = rand(1..10_000)
    @tank_volume = tank_volume
    @tank_level = tank_level
  end

  def litres_to_fuel
    @litres_to_fuel ||= tank_volume - tank_level
  end
end
