# frozen_string_literal: true

class Queue
  attr_reader :station, :queue

  # longest debug is when you write 'initalize'
  def initialize(station:)
    @station = station
    @queue = station.queue
  end

  def push(car)
    queue << car
    car.entry_tick = Timer.instance.current_tick

    Logger.info("Car##{car.id} has arrived and is #{queue.size} in queue")
  end

  def shift
    queue.shift
  end

  def consume
    return unless (car = queue.shift)
    station.request_fueling(car)
  end
end
