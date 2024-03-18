module Petrolex
  # Syncs simulation time
  class CarsAuthority
    def initialize
      @last_plate = 0
    end

    @instance = new

    def self.instance
      @instance
    end

    def generate
      self.last_plate += 1
      last_plate.to_s.rjust(6, '0')
    end

    private

    attr_accessor :last_plate
  end
end
