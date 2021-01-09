require_relative 'test_helper'

class CarTest < Minitest::Test
  include ::TestHelper

  def test_car_fuels
    car = Car.new(tank_volume: 50, tank_level: 20)
    station = Station.new(is_occupied: false)

    stub_waiting { car.try_to_fuel(station) }

    assert_equal 50, car.tank_level
  end

  def test_car_doesnt_fuel_if_station_busy_and_no_retry
    car = Car.new(tank_volume: 50, tank_level: 20, retry_fueling: false)
    station = Station.new(is_occupied: true)

    stub_waiting { car.try_to_fuel(station) }

    assert_equal 20, car.tank_level
  end

  def test_car_fuels_if_station_not_busy_and_no_retry
    car = Car.new(tank_volume: 50, tank_level: 20, retry_fueling: false)
    station = Station.new(is_occupied: false)

    stub_waiting { car.try_to_fuel(station) }

    assert_equal 50, car.tank_level
  end
end
