class WaterObject < MovingObject
  def initialize(*args)
    super(*args)
    @vertices = [[0, 0], [-10, -10], [+10, -10]]
    @destroy_delay = nil
  end

  def draw(view_x, view_y)
    #@game.images["lichtschalter.png"].draw_rot(@x - view_x, @y - view_y, ZOrder::MenuFront)
  end

  def touch_ground
    @destroy_delay ||= 400
  end
  
  def update()
    # partikel-fx!
    
    Particle.new(self.game, self.x + 15 - rand(31), self.y + 0 - rand(12), 1 - rand(3), 2 - rand(3), 0, 20 + rand(15), Gosu::Color.new(0xCC0000f0), 20, 0)    
    Particle.new(self.game, self.x + 10 - rand(21), self.y - 5 - rand(12), 0, 0, 0, 20 + rand(15), Gosu::Color.new(0xCC6363a9), 20, 0)

    fall
    super

    exists = true
    if @destroy_delay then
      @destroy_delay -= 1
      exists = false if @destroy_delay <= 0
    end

    return exists
  end
end
