require_relative 'test_helper'

class TestStation < Minitest::Test
  include ::TestHelper

  def test_handles_fueling_request
    car = Car.new(tank_volume: 50, tank_level: 20)
    station = Station.new

    stub_waiting { station.request_fueling(car, 30) }

    assert_equal 50, car.tank_level
  end
end
