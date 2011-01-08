require 'gameobject'
require 'particle'

class Fireball < GameObject
  def initialize(game, x, y, vx, vy)
    super(game, x, y)
    @vx, @vy = vx, vy
  end
  
  def update
    Particle.new(self.game, self.x, self.y, 1 - rand(3), 1 - rand(3), 0, 30, Gosu::Color.new(0x99ff3300), 10, 0)
    Particle.new(self.game, self.x, self.y, 0, 0, 0, 10 + rand(10), Gosu::Color.new(0x99ffff00), 13, 0)
  
    self.x += @vx
    self.y += @vy

    return false if @game.map.do_fire(@x, @y)
    
    not self.game.map.solid?(self.x, self.y)
  end
 end
#end