require 'particle'

class Bulbhelfer < GameObject
  def initialize(game, x, y)
    super(game, x, y)
    @alive = true
  end
  
  def draw(screen_x, screen_y)
        5.times do |i|
        left, top, right, bottom = *light_rect(self.x / 50 + 2 - i, self.y / 50)
        self.game.main.draw_quad(left - screen_x, top - screen_y, 0x80ffff99,
          right - screen_x, top - screen_y, 0x80ffff99,
          left - screen_x, bottom - screen_y, 0x80ffff99,
          right - screen_x, bottom - screen_y, 0x80ffff99,
          ZOrder::Lighting)
      end
  end
  
  def next_solid_tile_below(tile_x, tile_y)
    res = tile_y
    res += 1 until self.game.map.solid?(tile_x * 50, res * 50)
    res
  end
  
  def light_rect(tile_x, tile_y)
    [tile_x * 50, tile_y * 50, tile_x * 50 + 50, next_solid_tile_below(tile_x, tile_y) * 50]
  end
  
  def deactivate
    @alive = false
    self.game.map.set(self.x /  50, self.y / 50, Map::LightBulbOff)
  end

  def update
    self.game.objects.grep(Player).each do |plr|
        5.times do |i|
          left, top, right, bottom = *light_rect(self.x / 50 + 2 - i, self.y / 50)
          if plr.x > left and plr.x < right and plr.y > top and plr.y < bottom then
            plr.unsleep(0.2)
          end
        end
    end
   
    @alive
  end
  
  
end
