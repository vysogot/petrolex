# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Report do
    before do
      @report = Report.new(name: 'TestRun')
      @station = 'Alpha'
      @car1 = Car.new(plate: 'PGN-1', volume: 50, level: 10)
      @car2 = Car.new(plate: 'WAW-2', volume: 30, level: 0)
    end

    def sheet
      @report.for(station_name: @station)
    end

    # --- record management ---

    it 'adds and counts waiting records' do
      sheet.add_record(record: { status: :waiting, car: @car1 })
      _(sheet.waiting_count).must_equal 1
    end

    it 'removes waiting records by car identity' do
      sheet.add_record(record: { status: :waiting, car: @car1 })
      sheet.remove_record(record: { status: :waiting, car: @car1 })
      _(sheet.waiting_count).must_equal 0
    end

    it 'tracks full, partial, and none records separately' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 0.4 })
      sheet.add_record(record: { status: :partial, car: @car2, units_given: 15, units_wanted: 30,
                                 fueling_time: 5, waiting_time: 1, bill: 30.0, cost: 0.15 })

      _(sheet.full_count).must_equal 1
      _(sheet.partial_count).must_equal 1
      _(sheet.none_count).must_equal 0
    end

    # --- aggregations ---

    it 'counts visitors as waiting + full + partial + none' do
      sheet.add_record(record: { status: :waiting, car: @car1 })
      sheet.add_record(record: { status: :full, car: @car2, units_given: 30, units_wanted: 30,
                                 fueling_time: 6, waiting_time: 1, bill: 60.0, cost: 0.3 })
      _(sheet.visitors_count).must_equal 2
    end

    it 'includes full and partial in served' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 0.4 })
      sheet.add_record(record: { status: :partial, car: @car2, units_given: 15, units_wanted: 30,
                                 fueling_time: 5, waiting_time: 1, bill: 30.0, cost: 0.15 })
      _(sheet.served.size).must_equal 2
    end

    it 'sums fuel given across served cars' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 0.4 })
      sheet.add_record(record: { status: :partial, car: @car2, units_given: 15, units_wanted: 30,
                                 fueling_time: 5, waiting_time: 1, bill: 30.0, cost: 0.15 })
      _(sheet.fuel_given).must_equal 55
    end

    # --- averages ---

    it 'returns zero avg_waiting_time when no cars served' do
      _(sheet.avg_waiting_time).must_equal 0
    end

    it 'computes avg_waiting_time across all served and none cars' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 4, bill: 80.0, cost: 0.4 })
      sheet.add_record(record: { status: :full, car: @car2, units_given: 30, units_wanted: 30,
                                 fueling_time: 6, waiting_time: 2, bill: 60.0, cost: 0.3 })
      _(sheet.avg_waiting_time).must_equal 3.0
    end

    it 'returns zero avg_fueling_time when nothing served' do
      _(sheet.avg_fueling_time).must_equal 0
    end

    it 'computes avg_fueling_time correctly' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 10, waiting_time: 2, bill: 80.0, cost: 0.4 })
      sheet.add_record(record: { status: :partial, car: @car2, units_given: 15, units_wanted: 30,
                                 fueling_time: 6, waiting_time: 1, bill: 30.0, cost: 0.15 })
      _(sheet.avg_fueling_time).must_equal 8.0
    end

    # --- financials ---

    it 'computes total income from bills' do
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 0.4 })
      _(sheet.total_income).must_equal 80.0
    end

    it 'computes total_revenue as income minus total cost' do
      sheet.update_costs(initial_fuel_cost: 10.0, initial_pumps_cost: 5.0)
      sheet.add_record(record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                                 fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 2.0 })
      # total_cost = 10 + 5 + 2 = 17, total_income = 80, revenue = 63
      _(sheet.total_revenue).must_equal 63.0
    end

    # --- reserve and costs ---

    it 'tracks reserve' do
      sheet.update_reserve(count: 500)
      _(sheet.reserve).must_equal 500
    end

    it 'returns zero reserve when not set' do
      _(sheet.reserve).must_equal 0
    end

    it 'stores and rounds initial costs' do
      sheet.update_costs(initial_fuel_cost: 100.333, initial_pumps_cost: 50.666)
      _(sheet.initial_fuel_cost).must_equal 100.33
      _(sheet.initial_pumps_cost).must_equal 50.67
    end

    # --- isolation between stations ---

    it 'keeps data isolated between different stations' do
      @report.for(station_name: 'Alpha').add_record(
        record: { status: :full, car: @car1, units_given: 40, units_wanted: 40,
                  fueling_time: 8, waiting_time: 2, bill: 80.0, cost: 0.4 }
      )
      @report.for(station_name: 'Beta').add_record(
        record: { status: :full, car: @car2, units_given: 30, units_wanted: 30,
                  fueling_time: 6, waiting_time: 1, bill: 60.0, cost: 0.3 }
      )

      _(@report.for(station_name: 'Alpha').full_count).must_equal 1
      _(@report.for(station_name: 'Beta').full_count).must_equal 1
      _(@report.for(station_name: 'Alpha').fuel_given).must_equal 40
      _(@report.for(station_name: 'Beta').fuel_given).must_equal 30
    end
  end
end
