# frozen_string_literal: true

module Petrolex
  class Report
    attr_reader :name, :document

    def initialize(name:)
      @name = name
      @document = {}
    end

    def for(station_name:)
      StationSheet.new(document:, station_name:)
    end
  end
end
