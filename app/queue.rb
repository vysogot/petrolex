# frozen_string_literal: true

class Queue
  attr_reader :station, :queue

  def initialize(station:)
    @station = station
    @queue = station.queue
  end

  def push(car)
    queue << car
    car.entry_tick = Timer.instance.current_tick

    Logger.info("Car##{car.id} has arrived and is #{queue.size} in queue")
  end

  def consume
    return unless (car = first_in_line)
    station.request_fueling(car)
  rescue Station::NotEnoughFuel
    Logger.info("Car##{car.id} needed #{car.litres_to_fuel} litres and has left due to lack of fuel")
  end

  private

  def first_in_line
    queue.shift
  end
end
