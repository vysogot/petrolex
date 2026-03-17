# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Plater do
    before do
      @plater = Plater.new
    end

    it 'generates plates with incrementing numbers' do
      first = @plater.request_plate
      second = @plater.request_plate

      first_num = first.split('-').last.to_i
      second_num = second.split('-').last.to_i

      _(second_num).must_equal first_num + 1
    end

    it 'generates plates with known prefix' do
      plate = @plater.request_plate
      prefix = plate.split('-').first

      _(Plater::PREFIXES).must_include prefix
    end

    it 'generates unique plates across calls' do
      plates = 10.times.map { @plater.request_plate }
      _(plates.uniq.size).must_equal 10
    end
  end
end
