# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Car do
    before do
      @car = Car.new(plate: 'PGN-1', volume: 50, level: 30)
    end

    it 'reports how much fuel it wants' do
      _(@car.want).must_equal 20
    end

    it 'increases level when fueled' do
      @car.fuel(10)
      _(@car.level).must_equal 40
    end

    it 'represents itself as its plate' do
      _(@car.to_s).must_equal 'PGN-1'
    end

    it 'starts with the initial level' do
      _(@car.level).must_equal 30
    end

    it 'want is zero when tank is full' do
      full_car = Car.new(plate: 'WAW-1', volume: 40, level: 40)
      _(full_car.want).must_equal 0
    end
  end
end
