class GameObject
  attr_accessor :game, :x, :y
  
  def initialize(game, x, y)
    @game = game
    @game.add_object(self)
    @x, @y = x, y
  end

  def warp_to(new_x, new_y)
    @x = new_x
    @y = new_y
  end
  
  def update
    true
  end
  
  def draw(screen_x, screen_y)
  end
end
