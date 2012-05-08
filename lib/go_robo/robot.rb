require 'fiber'
module GoRobo
class Robot

  attr_reader :health, :x, :y, :name, :direction, :id, :robo_type

  def initialize(options={}, &proc)
    opt = options.dup
    # @health = opt[:health] || 100
    @x = opt[:x] || 0
    @y = opt[:y] || 0
    @direction = opt[:direction]
    @name = opt[:name]
    @robo_type = self.class.name
    @id = self.object_id

    @thread = Fiber.new do
      self.instance_eval &proc
    end
  end

  def player?
    false
  end

  def others
    candidates = World.robots.select do |o|
      unless o.is_a? Rocket
        delta = {:x => o.x - self.x, :y => o.y - self.y}

        case @direction
        when 0
          o.y > self.y && delta[:y] >= delta[:x].abs
        when 90
          o.x > self.x && delta[:x] >= delta[:y].abs
        when 180
          o.y < self.y && delta[:y] >= delta[:x].abs
        when 270
          o.x < self.x && delta[:x] >= delta[:y].abs
        end

      end
    end

    candidates.select{|c| clear_path?(c.x, c.y, self, candidates)}
  end

  def clear_path?(x, y, o, candidates)
    while (true)
      delta = {:x => o.x - x, :y => o.y - y}

      if delta[:x] == 0 && delta[:y] == 0
        return true
      elsif delta[:x] > 0 && delta[:x] >= delta[:y].abs
        x += 1
      elsif delta[:y] > 0 && delta[:y] >= delta[:x].abs
        y += 1
      elsif delta[:x] < 0 && delta[:x].abs >= delta[:y].abs
        x -= 1
      else delta[:y] < 0 && delta[:y].abs >= delta[:x].abs
        y -= 1
      end

      if c = candidates.find{|c| c.x == x && c.y == y && c != o}
        return false
      end
    end
  end

  def run
    @thread.resume if @thread.alive?
  end

  def move(dist)
    dist = @max_dist if dist > @max_dist
    dist.times do
      old_location = [@x, @y]
      case @direction
      when 0
        @y -= 1
      when 90
        @x += 1
      when 180
        @y += 1
      when 270
        @x -= 1
      else
        raise "That direction is an invalid."
      end
      break if World.detect_collisions(self, old_location)
    end

    end_round
  end

  def turn(dir)
    if [1,-1].include?(dir)
      @direction += dir*90
      @direction = 270 if @direction == -90
      @direction = 0 if @direction == 360
    else
      raise "You can only turn in 90-degree turning turns."
    end
    end_round
  end

  def collide(options={})
    opt = options.dup
    self.hit(opt[:damage])
    if opt[:new_location] && alive?
      @x = opt[:new_location].first
      @y = opt[:new_location].last
    end
  end

  def shoot
    World.rocket(self)
    end_round
  end

  def wait
    end_round
  end

  def hit(amount)
    @health -= amount
  end

  def dead?
    health <= 0
  end

  def alive?
    !dead?
  end

protected
  attr_writer :health, :x, :y, :name, :direction, :max_dist, :strength

private
  def end_round
    die if dead?
    Fiber.yield
  end

  def die

  end
end
end