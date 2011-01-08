class Bed < GameObject
  def initialize(game, x, y)
    super(game, x, y)
    @images = game.images["Bed.png", 150, 100]
  end
  
  def draw(screen_x, screen_y)
    phase = @phase || 0
    hannelore = (phase * 255).round
    quad_color = Color.new(hannelore, 0, 0, 0)
    bed_color = Color.new(255 - hannelore, 255, 255, 255)
    
    self.game.main.draw_quad(0, 0, quad_color, 800, 0, quad_color, 0, 600, quad_color, 800, 600, quad_color, ZOrder::FadeOut)
    
    @images[@phase ? 1 : 0].draw_rot(x - screen_x, y - screen_y, @phase ? ZOrder::Effect : ZOrder::Object, 0, 0.5, 0.5,
      1.0 + phase * 2, 1.0 + phase * 2, bed_color)
  end
  
  def reach
    @phase = 0
  end
  
  def update
    if not @phase then
      return true
    end
  
    @phase = [@phase + 0.01, 1].min
    if @phase == 1 then
      self.game.next_level
    end
    
    true
  end
end
