# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  class StationTest < Minitest::Test
    include ::QuietLogger

    def test_handles_fueling_request
      car = Car.new(tank_volume: 50, tank_level: 20)
      station = Station.new(is_open: true)

      car.queue_up(station)
      station.request_fueling(car, 30)

      assert_equal 50, car.tank_level
    end

    def test_opens
      station = Station.new
      refute station.is_open

      station.open
      assert station.is_open

      station.close
      refute station.is_open
    end

    def test_enqueues_cars
      car1, car2, car3 = Array.new(3) { Car.new }
      station = Station.new

      station.enqueue(car1)
      station.enqueue(car3)
      station.enqueue(car2)

      assert [car1, car3, car2], station.queue
    end

    def test_fuels_cars_in_queue
      car1, car2, car3 = Array.new(3) { Car.new }
      station = Station.new

      station.enqueue(car1)
      station.enqueue(car3)
      station.enqueue(car2)

      station.consume_queue

      assert [car3, car2], station.queue
    end
  end
end
