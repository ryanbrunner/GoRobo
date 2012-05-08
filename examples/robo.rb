autoload :World, './gorobo/world'
autoload :Robot, './gorobo/robot'
require './gorobo/types'
require 'active_support'

r = Speedy.new(:x => 5, :y => 10, :direction => 0, :name => 'Ryan') do
  def align(r)
    align_loc(r.x, r.y)
  end

  def align_loc(x, y)
    if x == self.x
      if (y < self.y)
        while (direction != 0)
          turn(1)
        end
      else
        while (direction != 180)
          turn(1)
        end
      end
    else
      if (x < self.x)
        while (direction != 270)
          turn(1)
        end
      else
        while (direction != 90)
          turn(1)
        end
      end
    end
  end

  def move_to_loc(x, y)
    while self.x != x || self.y != y
      align_loc x, y
      move 1
      patrol
    end
  end

  def patrol
    turn 1
    check_for_enemies
    turn -1
    turn -1
    check_for_enemies
    turn 1
  end

  def close_to_wall
    (x <= 1 && direction == 270) ||
    (y <= 1 && direction == 0) ||
    (x >= 29 && direction == 90) ||
    (y >= 29 && direction == 180)
  end

  def get_to_da_choppa
    left = (x < 15)
    up = (y < 15)
    if left && up
      get_to_choppa_number 1
    elsif left && !up
      get_to_choppa_number 2
    elsif !left && up
      get_to_choppa_number 3
    else
      get_to_choppa_number 4
    end
  end

  def get_to_choppa_number(num)
    case num
    when 1
      move_to_loc(0,0)
      align_loc(30,0)
    when 2
      move_to_loc(0,30)
      align_loc(30,30)
    when 3
      move_to_loc(30,0)
      align_loc(30,30)
    else
      move_to_loc(30,30)
      align_loc(0,0)
    end
  end

  def turn_around
    turn(1)
    turn(1)
  end

  def check_for_enemies
    players = others.select(&:player?)
    if players.any?
      5.times { shoot }
    end
  end

  while (true)
    get_to_da_choppa
    players = others.select(&:player?)

    while(true)
      get_to_choppa_number rand(4)
    end
  end
end

r2 = Speedy.new(:x => 0, :y => 30, :direction => 0, :name => 'AidanBot') do
  while(true)
    move 15
    turn 1
    move 15
    while(true)
      turn 1
      shoot
    end
  end
end

r4 = Speedy.new(:x => 30, :y => 30, :direction => 0, :name => 'Emery') do
  while(true)
    7.times { move 2; turn -1; move 2; turn 1}
    4.times { shoot; turn 1 }
    4.times { shoot; turn 1 }
  end
end



r3 = Speedy.new(:x => 30, :y => 0, :direction => 180, :name => 'Grrl') do
    while(true)
      move(1)
      turn(-1)
      shoot
    end
  end





r13 = Speedy.new(:x => 15, :y => 5, :direction => 180, :name => 'hacked') do
  while(true)
    walls = [];
    players = [];

    others.each do |thing|
      # players?
      if(thing.player?)
        if(x == thing.x || y == thing.y)
          shoot
        end

        leftovers = {
          x: thing.x,
          y: thing.y,
          dx: (thing.x - x),
          dy: (thing.y - y)
        }

        leftovers[:magnitude] = Math.sqrt(leftovers[:dx] * leftovers[:dx] + leftovers[:dy] * leftovers[:dy])

        players << leftovers
      else
        walls << thing
      end
    end

    if(players.any?)
      players.sort! { |a,b| a.magnitude <=> b.magnitude }
      player = players[0]

      # true -- move on x axis
      # true -- pointing to x axis
      if(player[:dx].abs > player[:dy].abs == direction % 180)
        move(player[:dx].abs)
      else
        turn(1)
      end
    else
      # do something smarter here
      turn(1)
    end

    # do some wall stuff
  end
end



walls = (10..20).map { |i| Wall.new(:x => i, :y => 15, :direction => 180, :name => "Wall #{i}") }
walls += (10..20).map { |i| Wall.new(:x => 15, :y => i, :direction => 180, :name => "Vert Wall #{i}") }

World.setup [
  r, r2, r3, r4, r13
] + walls

#puts World.print_status
#r.others.each do |robot|
#  puts robot.name
#end

World.interactive_run
# puts ActiveSupport::JSON.encode(World.run)