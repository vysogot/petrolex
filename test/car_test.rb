# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Car do
    before do
      tank_volume, tank_level = 50, 30
      @car = Car.new(tank_volume:, tank_level:)
    end

    it 'returns right amount of litres to fuel' do
      _(@car.litres_to_fuel).must_equal 20
    end
  end
end
