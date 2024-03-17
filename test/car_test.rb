# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  class CarTest < Minitest::Test
    include ::QuietLogger

    def test_car_fuels
      car = Car.new(tank_volume: 50, tank_level: 20)
      station = Station.new(is_occupied: false, is_open: true)

      car.queue_up(station)
      car.try_to_fuel(station)

      assert_equal 50, car.tank_level
    end

    def test_car_doesnt_fuel_if_station_busy
      car = Car.new(tank_volume: 50, tank_level: 20)
      station = Station.new(is_occupied: true, is_open: true)

      car.queue_up(station)
      car.try_to_fuel(station)

      assert_equal 20, car.tank_level
    end

    def test_car_fuels_if_station_not_busy_and_no_retry
      car = Car.new(tank_volume: 50, tank_level: 20)
      station = Station.new(is_occupied: false, is_open: true)

      car.queue_up(station)
      car.try_to_fuel(station)

      assert_equal 50, car.tank_level
    end

    def test_car_gets_in_queue
      car1, car2, car3 = Array.new(3) { Car.new }
      station = Station.new

      car1.queue_up(station)
      car3.queue_up(station)
      car2.queue_up(station)

      assert [car1, car2, car3].all?(&:in_queue)
    end

    def test_car_gets_fueled_after_queue_consumtion
      car = Car.new(tank_volume: 50, tank_level: 20)
      station = Station.new(is_open: true)

      car.queue_up(station)
      car.try_to_fuel(station)

      assert_equal 50, car.tank_level
    end
  end

  class CarTestWithLogger < Minitest::Test
    include ::SerialFaker

    def test_logs_queue_position_of_car
      car1, car2, car3 = Array.new(3) { Car.new }
      station = Station.new

      Logger.stub :info, nil do
        car1.queue_up(station)
        car3.queue_up(station)
      end

      Timer.instance.stub :current_tick, 20 do
        output = catch_output do
          car2.queue_up(station)
        end

        assert_equal "00020: Car##{car2.id} has arrived and is #{car2.in_queue} in queue", output.chomp
      end

      assert [car1, car2, car3].all?(&:in_queue)
    end
  end
end
