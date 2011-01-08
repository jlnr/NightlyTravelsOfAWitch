class ItemFx < GameObject
  def initialize(game, x, y, item)
    super(game, x, y)

    @image = game.images["items.png", ItemDrawer::ItemWidth, ItemDrawer::ItemHeight][item]
    @color = Color.new(0xFFFFFFFF)
    @size = 1.0
    @time = 1 # 1 .. 100
  end

  def draw(screen_x, screen_y)
    @image.draw_rot(@x - screen_x, @y - screen_y, ZOrder::Effect, 0, 0.5, 0.5, @size, @size, @color)
  end

  def update()
    @time += 4
    @color.alpha = (255 - @time * (255 / 103.0)).round
    @size = @time / 100.0 * 3
    return @time < 100
  end
end

