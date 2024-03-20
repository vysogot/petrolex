# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Queue do
    include QuietLogger

    before do
      dispenser = Dispenser.new(fueling_speed: 0.5)
      station = Station.new(fuel_reserve: 1000, dispenser:)
      @queue = Queue.new(station:)

      @car1 = Car.new(plate: '000001', tank_volume: 50, tank_level: 30)
      @car2 = Car.new(plate: '000002', tank_volume: 70, tank_level: 10)

      station.open
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
      _(@car1.send(:tank_level)).must_equal @car1.send(:tank_volume)
    end
  end
end
