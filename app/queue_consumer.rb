# frozen_string_literal: true

# Handles queue of cars at a station
class QueueConsumer
  attr_reader :consumer, :station, :closing_tick, :refresh_step

  def initialize(station:,
                 closing_tick: 500,
                 refresh_step: 1)
    @station = station
    @consumer = ENV['app_env'] == 'test' ? mock : real
    @closing_tick = closing_tick
    @refresh_step = refresh_step
  end

  private

  def real
    Thread.new do
      loop do
        station.consume_queue
        break unless station.is_open

        if Timer.instance.current_tick >= closing_tick
          station.close
          break
        end

        Timer.instance.wait(refresh_step)
      end
    end
  end

  def mock
    Thread.new {}
  end
end
