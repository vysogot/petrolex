class Roadie
  CARS = {
    taxi: "\u{1F695}",
    blue_car: "\u{1F699}",
    red_car: "\u{1F697}",
    bus: "\u{1F68C}",
    police_car: "\u{1F693}",
    fire_engine: "\u{1F692}",
    truck: "\u{1F69A}",
    ambulance: "\u{1F691}"
  }

  attr_accessor :car, :row, :column, :direction, :moving
  attr_reader :emoji, :wants_fuel

  def initialize(car:, row:, column:, direction: :left)
    @car = car
    @row = row
    @column = column
    @direction = direction
    @emoji = CARS.values.sample
    @wants_fuel = true#rand(0..1).odd?
    @moving = true
  end

  def at?(given_row:, given_column:)
    row == given_row && column == given_column
  end

  def wants_fuel?
    wants_fuel
  end

  def going_left?
    direction == :left
  end

  def going_down?
    direction == :down
  end

  def going_up?
    direction == :up
  end

  def moving?
    moving
  end

  def turn_left
    self.direction = :left
  end

  def turn_down
    self.direction = :down
  end

  def turn_up
    self.direction = :up
  end

  def stop_moving
    self.moving = false
  end

  def start_moving
    self.moving = true
  end
end
