require 'background'
require 'particle'
require 'map'
require 'itemdrawer'
require 'totd'
require 'gameover'

class Game < SubApp
  attr_reader :main, :map, :mouse_x, :mouse_y, :images, :item_drawer, :ticks, :objects
  def initialize(main, num)
    super(main)
    @first_password = true
    reinitialize(main, num)
  end

  def reinitialize(main, num)
    @main = main
    @num = num
    
    @images = Hash.new do |hash, key|
      filename, tile_width, tile_height, hard_borders = *key
      hard_borders = false if hard_borders == nil
      tile_width ||= -1
      tile_height ||= -1
      result = Image.load_tiles(main, File.join("media", filename), tile_width, tile_height, hard_borders)
      hash[key] = (result.size <= 1 && tile_width == -1 && tile_height == -1) ? result.first : result
    end
    def @images.[](*args)
      super(args)
    end

    @ticks = 0
    @background = Background.new(self)
    @objects = []
    @item_drawer = ItemDrawer.new(self, LevelItems[num - 1])
    @map = Map.new(self, num)
    @center_x = @view_x = [(@objects.grep(Player).first.x rescue @map.width / 2) - @main.height / 2, 0].max
    @center_y = @view_y = [(@objects.grep(Player).first.y rescue @map.height / 2) - @main.width / 2, 0].max
    @scroll_border_size = @main.width / 10.0
    @scrolling = 0.96
    @mouse_gfx = @images["cursor.png", 40, 40, false]
    @paused_gfx = @images["paused.png"]
    @paused = false
    @password_gfx = @images["items.png", ItemDrawer::ItemWidth, ItemDrawer::ItemHeight]
    @zzz_gfx = @images["zzz.png"]
    @restart_gfx = @images["restart.png"]
    # just in case.
    @mouse_x = @mouse_y = 0
    @mouse_dir = 1.0
    @seen_password = @seen_totd = false
    @zzz_level = 1
  end

  def restart_level()
    reinitialize(@main, @num)
    @seen_password = true
  end

  def do_restart()
    GameOver.new(self, true).show
  end
  
  def activate()
    unless @seen_password
      @seen_password = true
      if @first_password then
        @first_password = false
      else
        Password.new(@main, lambda { self }, nil, @num).show
        return
      end
    end

    unless @seen_totd
      @seen_totd = true
      Totd.new(@main, lambda {self}, LevelTips[@num - 1]).show
      return
    end
  end

  def button_up(button_id)
    if @paused then
      case button_id
        when @main.char_to_button_id("p"), *Buttons[:Escape] then
          @paused = false
      end
    else
      case button_id
        when *Buttons[:Escape] then
          close
        when Button::MsLeft, *Buttons[:Fire] then
          click(@main.mouse_x, @main.mouse_y)
        when Button::MsRight
          @item_drawer.unset_active_item
        when @main.char_to_button_id("p") then
          @paused = true
        when @main.char_to_button_id("r") then
          do_restart
      end
    end
  end
  
  def add_object(obj)
    @objects << obj
  end

  def zzz_x()
    @main.width - @zzz_gfx.width / 2 - 10
  end

  def zzz_y()
    @main.height - @zzz_gfx.height / 2 - 10
  end

  def zzz_scale()
    [@zzz_level, 0.6].max
  end

  def restart_x()
    @restart_gfx.width / 2 + 10
  end

  def restart_y()
    @main.height - @restart_gfx.height / 2 - 10
  end
  
  def click_restart(x, y)
    return if Gosu.distance(x, y, restart_x, restart_y) > (1 * @restart_gfx.width) / 2

    do_restart
  end
  
  def click(mouse_x, mouse_y)
    return if @item_drawer.click(mouse_x, mouse_y)
    return if click_restart(mouse_x, mouse_y)
    return if @objects.grep(Player).any? do |player|
      player.click(mouse_x + @view_x, mouse_y + @view_y)
    end
  end
  
  def draw()
    @item_drawer.draw(@view_x, @view_y)
    
    active_img = @item_drawer.active_item_image
    mouse_off = active_img ? 2 : 0

    @zzz_level = @objects.grep(Player).inject(1) { |res, player| player.update_zzz_level; res * player.zzz_level }
    scale = zzz_scale
    @zzz_gfx.draw_rot(zzz_x, zzz_y, ZOrder::GUIFront,
      0, 0.5, 0.5, scale, scale, Color.new((@zzz_level * 255).to_i, 255, 255, 255))

    @restart_gfx.draw_rot(restart_x, restart_y, ZOrder::GUIFront, 0)
      
    @mouse_gfx[mouse_off + milliseconds / 200 % 2].draw(@main.mouse_x - 15 * @mouse_dir, @main.mouse_y - 20, ZOrder::Mouse,
      @mouse_dir, 1.0)
    active_img.draw(@main.mouse_x - 7, @main.mouse_y - 10, ZOrder::MouseItem, 0.2, 0.2) if active_img
    @map.draw(@view_x, @view_y)
    @objects.each { |obj| obj.draw(@view_x, @view_y) }
    @main.draw_quad(0, 0, 0x801070B0, 800, 0, 0x801070B0,
      0, 600, 0x801070B0, 800, 600, 0x801070B0, ZOrder::Background)
    @background.draw(@view_x, @view_y)

    if @paused then
      c = 0xAAFFFFFF
      @main.draw_quad(0,0,c, @main.width,0,c, 0,@main.height,c, @main.width,@main.height,c, ZOrder::MenuBack)
      @paused_gfx.draw((@main.width - @paused_gfx.width) / 2, (@main.height - @paused_gfx.height) / 2,
        ZOrder::MenuFront)
    end
  end
    
  def play_sound(name, x, y, speed = 1.0)
    if (x - @view_x - 400).abs > 800 or (y - @view_y - 300).abs > 400 then
    return
    end
  
    @samples ||= Hash.new
    @samples[name] ||= Gosu::Sample.new(main, "sounds/#{name}")
    pan = [[(x - @view_x - 400) / 400.0, -1].max, 1].min
    dist = (x - @view_x - 400).abs
      if dist < 400 then
        vol = 1
      else
        vol = (800 - dist) / 400.0
      end
    @samples[name].play_pan(pan, vol, speed)
  end
    
  def update()
    catch(:next_level) do
      return false if @paused
      @ticks += 1
      handle_map_scrolling()
      
      set_view(@center_x, @center_y)
      
      old_x = @mouse_x
      
      @mouse_x = @main.mouse_x.round + @view_x
      @mouse_y = @main.mouse_y.round + @view_y
      
      if @mouse_x < old_x then
        @mouse_dir = +1
      elsif @mouse_x > old_x
        @mouse_dir = -1
      end
      
      Particle.new(self, @mouse_x, @mouse_y, 1 - rand(3), 1 - rand(3), 0, 5, Color.new(255, 255, 255, 255), 20, 0)
  
      @item_drawer.update
      
      zzz_level_target = @objects.grep(Player).inject(1) { |res, player| res * player.zzz_level_target }
      if zzz_level_target == 0 then
        play_sound("lose.ogg", @view_x + @main.width / 2, @view_y + @main.height / 2, 1.0)
        GameOver.new(self).show
      end
      
      cur = 0
      max = @objects.size
      while cur < max do
        if @objects[cur].update then
          cur += 1
        else
          @objects.delete_at(cur)
          max -= 1
        end
      end
    end
  end
  
  def next_level
    reinitialize(@main, @num + 1)
    activate()
    throw(:next_level)
  end

  def handle_map_scrolling()
    mx = @main.mouse_x
    my = @main.mouse_y
    mw = @main.width
    mh = @main.height

    return if mx < 0 or my < 0 or mx > mw or my > mh

    sf = 3
    
    if mx < @scroll_border_size then
      @center_x += (mx - @scroll_border_size) / sf
    elsif mx > mw - @scroll_border_size then
      @center_x += (@scroll_border_size - (mw - mx)) / sf
    end

    if my < @scroll_border_size then
      @center_y += (my - @scroll_border_size) / sf
    elsif my > mh - @scroll_border_size then
      @center_y += (@scroll_border_size - (mh - my)) / sf
    end

    bf = 18
    {
      [Button::GpLeft, Button::KbLeft] => [-bf, 0],
      [Button::GpRight, Button::KbRight] => [+bf, 0],
      [Button::GpUp, Button::KbUp] => [0, -bf],
      [Button::GpDown, Button::KbDown] => [0, +bf]
    }.each do |buttons, (off_x, off_y)|
      if buttons.any? do |button|
        @main.button_down?(button)
      end then
        @center_x += off_x
        @center_y += off_y
      end
    end

    if @map.width < @main.width
      @center_x = (@map.width - @main.width) / 2
    else
      @center_x = [[@center_x, 0].max, @map.width - @main.width].min
    end
    
    if @map.height < @main.height
      @center_y = (@map.height - @main.height) / 2
    else
      @center_y = [[@center_y, 0].max, @map.height - @main.height].min
    end

  end

  def set_view(x, y)
    of, nf = @scrolling, 1.0 - @scrolling
    @view_x = (@view_x * of + x * nf).round
    @view_y = (@view_y * of + y * nf).round
  end
end
