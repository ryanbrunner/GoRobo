module GoRobo
class Rocket < Robot

  def initialize(options={},&proc)
    @health = 5
    @max_dist = 20
    @strength = 10
    super
  end

end

###

class FatAss < Robot

  def initialize(options={},&proc)
    @health = 200
    @max_dist = 1
    @strength = 10
    super
  end

  def player?
    true
  end

end

###

class Speedy < Robot

  def initialize(options={},&proc)
    @health = 60
    @max_dist = 10
    @strength = 10
    super
  end

  def player?
    true
  end

end

class Wall < Robot

  def initialize(options={},&proc)
    @health = 100000000
    @max_dist = 0
    @strength = 10
    super
  end

  def run
    #walls can't do anything.
  end
end
end