require 'simplecov'
SimpleCov.start

require_relative 'app'
require 'minitest/autorun'

module TestHelper
  def run
    Logger.stub :info, nil do
      super
    end
  end

  private

  def stub_waiting(&block)
    mock = Minitest::Mock.new
    def mock.wait; nil; end

    TimeService.stub :wait, mock do
      yield
    end
  end
end

class TestStation < Minitest::Test
  include ::TestHelper

  def test_handles_fueling_request
    car = Car.new(tank_volume: 50, tank_level: 20)
    station = Station.new

    stub_waiting { station.request_fueling(car, 30) }

    assert_equal 50, car.tank_level
  end
end

class TestCar < Minitest::Test
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
