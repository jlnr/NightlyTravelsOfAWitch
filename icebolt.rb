require 'gameobject'
require 'particle'

class Icebolt < GameObject
  def initialize(game, x, y, vx, vy)
    super(game, x, y)
    @vx, @vy = vx, vy
    @destroyed = false
  end

  def destroy()
    @destroyed = true
  end
  
  def update
    return false if @destroyed
    
    Particle.new(self.game, self.x, self.y, 1 - rand(3), 1 - rand(3), 0, 30, Gosu::Color.new(0x990099FF), 10, 0)
    Particle.new(self.game, self.x, self.y, 0, 0, 0, 10 + rand(10), Gosu::Color.new(0x9999FFFF), 13, 0)
  
    self.x += @vx
    self.y += @vy
    
    if self.game.map.get(self.x / 50, self.y / 50) == Map::Water then
      self.game.map.set(self.x / 50, self.y / 50, 18)
      30.times do
        Particle.new(self.game, self.x + 15 - rand(31), self.y + 15 - rand(31), 1 - rand(3), 1 - rand(3), 0, 30, Gosu::Color.new(0x990099FF), 10, 0)
        Particle.new(self.game, self.x + 10 - rand(21), self.y + 10 - rand(21), 0, 0, 0, 10 + rand(10), Gosu::Color.new(0x9999FFFF), 13, 0)
      end
      return false
    end

    @game.objects.grep(EvilFlame).each do |flame|
      if Gosu.distance(@x, @y, flame.x, flame.y - 20) < 20
        flame.destroy
      end
    end
  
    not self.game.map.solid?(self.x, self.y)
  end
end