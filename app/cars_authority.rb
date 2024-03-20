# frozen_string_literal: true

module Petrolex
  # Syncs simulation time
  class CarsAuthority
    PREFIXES = ['PGN', 'WAW', 'KRA']

    def initialize
      @last_plate = 0
    end

    @instance = new

    class << self
      attr_reader :instance
    end

    def request_plate
      generate
      distribute
    end

    private

    def generate
      self.last_plate += 1
    end

    def distribute
      district + '-' + last_plate.to_s.rjust(6, '0')
    end

    def district
      PREFIXES[rand(0..2)]
    end

    attr_accessor :last_plate
  end
end
