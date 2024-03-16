# frozen_string_literal: true

# Handles queue of cars at a station
class QueueConsumer
  attr_reader :consumer, :station, :closing_tick

  def initialize(station:, closing_tick:)
    @station = station
    @consumer = ENV['app_env'] == 'test' ? mock : real
    @closing_tick = closing_tick
  end

  private

  def real
    Thread.new do
      loop do
        station.consume_queue
        sleep(0.001)
        break unless station.is_open

        if Timer.instance.current_tick >= closing_tick
          station.close
          break
        end
      end
    end
  end

  def mock
    Thread.new {}
  end
end
