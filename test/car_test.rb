# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Car do
    before do
      volume = 50
      level = 30
      plate = '000001'
      @car = Car.new(plate:, volume:, level:)
    end

    it 'returns right amount of litres to fuel' do
      @car.fuel

      _(@car.level).must_equal 50
    end
  end
end
