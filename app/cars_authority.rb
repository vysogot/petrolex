# frozen_string_literal: true

module Petrolex
  # Gives plates to a car
  class CarsAuthority
    STARTS_FROM = 0
    GENERATION_STEP = 1
    PREFIXES = %w[PGN WAW KRA].freeze

    def initialize
      @last_plate = STARTS_FROM
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
      self.last_plate += GENERATION_STEP
    end

    def distribute
      "#{district}-#{last_plate}"
    end

    def district
      PREFIXES.sample
    end

    attr_accessor :last_plate
  end
end
