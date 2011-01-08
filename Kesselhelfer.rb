require 'particle'

class Kesselhelfer < GameObject
  def initialize(*args)
    super
    @active = true
    update
  end
  
  def draw(view_x, view_y)
    #@game.images["lichtschalter.png"].draw_rot(@x - view_x, @y - view_y, ZOrder::MenuFront)
  end
 
  def update
    @game.objects.each do |object|
      if object.is_a?(Player) and Gosu.distance(object.x, object.y, @x, @y) < 80 then
        object.unsleep
      elsif object.is_a?(Icebolt) or object.is_a?(WaterObject) and
        Gosu.distance(object.x, object.y, @x, @y) < 100 then
        object.destroy if object.is_a?(Icebolt)
        @active = false
        @game.map.do_smoke(@x, @y)
      end
    end
    
    Particle.new(self.game, self.x - 15 + rand(28), self.y + 8, 1 - rand(4), -1 + rand(2), 0.5, 18, Color.new(255, 70, 222, 46), 14, 1)
    Particle.new(self.game, self.x - 30 + rand(50), self.y + 92, 1 - rand(2), -2 + rand(3), 0, 21, Color.new(255, 0xC0, 50, 0), 13, 2)
    
    if rand(3) == 0 then
      Particle.new(self.game, self.x - 30 + rand(50), self.y + 92, 1 - rand(2), -1 + rand(1), 0, 14, Color.new(255, 0xCC, 0xBB, 0), 13, 2)
    end
    
    if (self.game.ticks + rand(100)) % 23 == 0 then
      self.game.play_sound("blub.ogg", self.x, self.y, 0.8 + rand(40) / 100.0)
    end

    return @active
  end
end
