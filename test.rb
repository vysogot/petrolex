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
    station = Station.new

    stub_waiting { car.try_to_fuel(station) }

    assert_equal 50, car.tank_level
  end
end
