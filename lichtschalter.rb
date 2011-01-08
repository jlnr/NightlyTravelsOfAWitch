class Lichtschalter < GameObject
  def initialize(game, x, y)
    super(game, x, y)
    @image = game.images["lichtschalter.png"]
  end
  
  def draw(screen_x, screen_y)
    @image.draw_rot(x - screen_x, y - screen_y, ZOrder::Object, 0)
  end
  
  def turn_off
    self.game.objects.grep(Bulbhelfer) do |helper|
      if (helper.x - self.x).abs < 250 and (helper.y - self.y + 250).abs < 250 then
        helper.deactivate
      end
    end
  end
end
