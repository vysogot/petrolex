# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Queue do
    include QuietLogger

    before do
      dispenser = Dispenser.new(fueling_speed: 0.5)
      station = Station.new(fuel_reserve: 1000, dispenser:)
      @queue = Queue.new(station:)

      @car1 = Car.new(tank_volume: 50, tank_level: 30)
      @car2 = Car.new(tank_volume: 70, tank_level: 10)
    end

    it 'adds cars to waiting line' do
      @queue.push(@car1)
      @queue.push(@car2)

      _(@queue.waiting).must_equal [@car1, @car2]
      _(@queue.fueled).must_equal []
      _(@queue.unserved).must_equal []
    end

    it 'consumes a car from a queue' do
      @queue.push(@car1)
      @queue.push(@car2)
      @queue.consume

      _(@queue.waiting).must_equal [@car2]
      _(@queue.fueled).must_equal [@car1]
      _(@queue.unserved).must_equal []
      _(@car1.tank_level).must_equal @car1.tank_volume
    end
  end
end

  #   def test_car_fuels
  #     car = Car.new(tank_volume: 50, tank_level: 20)
  #     station = Station.new(is_occupied: false, is_open: true)

  #     car.queue_up(station)
  #     car.try_to_fuel(station)

  #     assert_equal 50, car.tank_level
  #   end

  #   def test_car_doesnt_fuel_if_station_busy
  #     car = Car.new(tank_volume: 50, tank_level: 20)
  #     station = Station.new(is_occupied: true, is_open: true)

  #     car.queue_up(station)
  #     car.try_to_fuel(station)

  #     assert_equal 20, car.tank_level
  #   end

  #   def test_car_fuels_if_station_not_busy_and_no_retry
  #     car = Car.new(tank_volume: 50, tank_level: 20)
  #     station = Station.new(is_occupied: false, is_open: true)

  #     car.queue_up(station)
  #     car.try_to_fuel(station)

  #     assert_equal 50, car.tank_level
  #   end

  #   def test_car_gets_in_queue
  #     car1, car2, car3 = Array.new(3) do
  #       Car.new(tank_volume: 50, tank_level: 20)
  #     end
  #     station = Station.new

  #     car1.queue_up(station)
  #     car3.queue_up(station)
  #     car2.queue_up(station)

  #     assert [car1, car2, car3].all?(&:in_queue)
  #   end

  #   def test_car_gets_fueled_after_queue_consumtion
  #     car = Car.new(tank_volume: 50, tank_level: 20)
  #     station = Station.new(is_open: true)

  #     car.queue_up(station)
  #     car.try_to_fuel(station)

  #     assert_equal 50, car.tank_level
  #   end
  # end

  # class CarTestWithLogger < Minitest::Test
  #   include ::SerialFaker

  #   def test_logs_queue_position_of_car
  #     car1, car2, car3 = Array.new(3) do
  #       Car.new(tank_volume: 50, tank_level: 20)
  #     end
  #     station = Station.new

  #     Logger.stub :info, nil do
  #       car1.queue_up(station)
  #       car3.queue_up(station)
  #     end

  #     Timer.instance.stub :current_tick, 20 do
  #       output = catch_output do
  #         car2.queue_up(station)
  #       end

  #       assert_equal "00020: Car##{car2.id} has arrived and is #{car2.in_queue} in queue", output.chomp
  #     end

  #     assert [car1, car2, car3].all?(&:in_queue)
  #   end
  # end
