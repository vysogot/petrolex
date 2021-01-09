# frozen_string_literal: true

require_relative 'test_helper'

class StationTest < Minitest::Test
  include ::TestHelper

  def test_handles_fueling_request
    car = Car.new(tank_volume: 50, tank_level: 20)
    station = Station.new

    stub_waiting { station.request_fueling(car, 30) }

    assert_equal 50, car.tank_level
  end

  def test_opens
    station = Station.new(is_occupied: true)

    station.open

    assert station.is_open
  end
end
