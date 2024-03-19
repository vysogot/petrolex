# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Car do
    before do
      tank_volume = 50
      tank_level = 30
      plate = '000001'
      @car = Car.new(plate:, tank_volume:, tank_level:)
    end

    it 'returns right amount of litres to fuel' do
      _(@car.litres_to_fuel).must_equal 20
    end
  end
end
