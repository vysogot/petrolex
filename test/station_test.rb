# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Station do
    include TestHelpers

    def build_station(reserve: 100, pump_speeds: [1])
      pumps = pump_speeds.map { |s| Pump.new(speed: s) }
      sim = stub_simulation(name: 'TestStation')
      Station.new(
        simulation: sim,
        name: 'TestStation',
        reserve:,
        pumps:,
        fuel_price: 2.0,
        fuel_cost: 1.0,
        pump_base_cost: 10.0
      )
    end

    it 'starts closed' do
      station = build_station
      _(station.open?).must_equal false
      _(station.closed?).must_equal true
    end

    it 'opens and closes' do
      station = build_station
      station.open
      _(station.open?).must_equal true
      station.close
      _(station.closed?).must_equal true
    end

    it 'mounts pumps with sequential ids' do
      station = build_station(pump_speeds: [1, 2])
      ids = station.mounted_pumps.map(&:id)
      _(ids).must_equal %w[Pump1 Pump2]
    end

    it 'assigns itself to each pump' do
      station = build_station(pump_speeds: [1])
      _(station.mounted_pumps.first.station).must_equal station
    end

    it 'reduces reserve when fuel is taken' do
      station = build_station(reserve: 100)
      station.take_fuel(30)
      _(station.reserve).must_equal 70
    end

    it 'raises NoMoreFuel when reserve is insufficient' do
      station = build_station(reserve: 10)
      assert_raises(Station::NoMoreFuel) { station.take_fuel(20) }
    end

    it 'does not reduce reserve when NoMoreFuel is raised' do
      station = build_station(reserve: 10)
      station.take_fuel(10) rescue nil
      begin
        station.take_fuel(1)
      rescue Station::NoMoreFuel
        nil
      end
      _(station.reserve).must_equal 0
    end

    it 'computes average pump speed' do
      station = build_station(pump_speeds: [2, 4])
      _(station.avg_pumps_speed).must_equal 3
    end

    it 'is not done when open' do
      station = build_station
      station.open
      _(station.done?).must_equal false
    end

    it 'is done when closed and no pumps are busy' do
      station = build_station
      station.open
      station.close
      _(station.done?).must_equal true
    end
  end
end
