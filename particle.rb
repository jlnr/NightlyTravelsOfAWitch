require 'gameobject'

class Particle < GameObject
  def initialize(game, x, y, vx, vy, ay, size, color, fadeout, index)
    super(game, x, y)
    @vx, @vy, @ay, @size = vx, vy, ay, size
    @color, @fadeout, @index = color, fadeout, index
    
    @images = game.images["Particles.png", 20, 20, false]
  end
  
  def draw(screen_x, screen_y)
    @images[@index].draw_rot(self.x - screen_x, self.y - screen_y, ZOrder::Effect, 0, 0.5, 0.5,
      @size / 20.0, @size / 20.0, @color)
  end
  
  def update
    if @color.alpha <= @fadeout then
      false
    else
      @color.alpha -= @fadeout
      @x += @vx
      @y += @vy
      @vy += @ay
      true
    end
  end
end