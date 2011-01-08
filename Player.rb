require 'movingobject'
require 'fireball'
require 'icebolt'
require 'itemfx'

class Player < MovingObject
  attr_reader :zzz_level, :zzz_level_target
  
  def initialize(game, x, y)
    super(game, x, y)
    @images = game.images["Player.png", 100, 200]
    self.vertices = [[20, -45], [-20, -45], [20, 0], [-20, 0], [-20, 50], [20, 50], [20, 100], [-20, 100]]
    @dir = +1
    @status = nil
    @zzz_level_target = @zzz_level = 1.0 # 0 .. 1
    @no_hurt_delay = 0
    @base_color = @status_color = Color.new(0xFFFFFFFF)
    @status_shots = 0
    @anim = 0
    @keep_anim = 0
  end

  def unsleep(amount = 1)
    return false if @no_hurt_delay > 0
    @zzz_level_target = [0, @zzz_level_target - amount].max
    @no_hurt_delay = 20
    look_unsleepy
    self.game.play_sound("unsleep.ogg", self.x, self.y, 1.0)
    return true
  end

  def look_unsleepy()
    @anim = 7
    @keep_anim = 7
  end

  def look_awake()
    @anim = 8
    @keep_anim = 7
  end
  
  def draw(screen_x, screen_y)
    color = @status_color.mix(@base_color, @status_shots / 3.0)
                    
    @images[@anim].draw_rot(x - screen_x, y - screen_y + 2, ZOrder::Player, 0, 0.5, 0.5, @dir, 1, color)
  end
 
  def hit_test(mx, my, padx, pady)
    mx > @x - 20 - padx && my > @y - 45 - pady && mx < @x + 20 + padx && my < @y + 100 + pady
  end

  def update_zzz_level()
    adjustment = (@zzz_level_target - @zzz_level)
    adjustment /= adjustment.abs if adjustment.abs >= 1
    @zzz_level += adjustment / 10.0
    @zzz_level = 0 if @zzz_level < 0.01    
  end
  
  def update
    @no_hurt_delay -= 1 if @no_hurt_delay > 0
    
    self.fall
    
    # Follow the black chocolate!
    if @game.item_drawer.active_item == Items::Choco and @keep_anim == 0 and
      game.mouse_y > game.item_drawer.end_y
    then
      if self.x - 70 > game.mouse_x then
        @dir = -1
        3.times { if blocked?(-1, 0) then break else self.x -= 1 end }
        @anim = 1 + milliseconds / 130 % 4
        @keep_anim = 1
      elsif self.x + 70 < game.mouse_x
        @dir = +1
        3.times { if blocked?(+1, 0) then break else self.x += 1 end }
        @anim = 1 + milliseconds / 130 % 4
        @keep_anim = 1
      end
    end
    
    if @keep_anim > 0 then
      @keep_anim -= 1
    else
      @anim = 0
    end
    
    self.game.objects.grep(Bed) do |bed|
      if (bed.x - self.x).abs < 75 and (bed.y - self.y).abs < 75 then
        bed.reach
        return false
      end
    end
    
    super
    
    true
  end

  def click(mx, my)
    active_item = @game.item_drawer.active_item
    # Block -> Place tile (wtf why is this code in this file)
    if active_item == Items::Block and not self.game.map.get(mx.to_i / 50, my.to_i / 50) and not hit_test(mx, my, 50, 50) then
      self.game.map.set(mx.to_i / 50, my.to_i / 50, Map::Block)
      @game.item_drawer.use_active_item
      ItemFx.new(@game, mx, my, Items::Block)
    end
    
    # Spider -> poke
    if active_item == Items::Spider and hit_test(mx, my, 100, 0) then
      ItemFx.new(@game, mx, my, Items::Spider)
      self.game.objects.grep(Lichtschalter) do |switch|
        if (switch.x - mx).abs < 20 and (switch.y - my).abs < 20 then
          switch.turn_off
        end
      end
      @dir = self.x < mx ? +1 : -1
      @anim = 6
      @keep_anim = 10
    end
  
    # Orc -> shoot
    if active_item == Items::Orc then
      @dir = self.x < mx ? +1 : -1
      if @status == Items::Chili then
        angle = angle(self.x, self.y, mx, my)
        Fireball.new(self.game, self.x, self.y, offset_x(angle, 10).round, offset_y(angle, 10).round)
        @anim = 5
        @keep_anim = 10
        self.game.play_sound("castmagic.ogg", self.x, self.y, 1.0)
      end
      if @status == Items::Ice then
        angle = angle(self.x, self.y, mx, my)
        Icebolt.new(self.game, self.x, self.y, offset_x(angle, 10).round, offset_y(angle, 10).round)
        @anim = 5
        @keep_anim = 10
        self.game.play_sound("castmagic.ogg", self.x, self.y, 1.0)
      end
      #@status = nil
      ItemFx.new(@game, mx, my, Items::Orc)
      @status_shots -= 1 if @status_shots > 0
      @status = nil if @status_shots <= 0
      return
    end

    return if active_item == Items::Choco or not hit_test(mx, my, 0, 0)
    
    @status = @game.item_drawer.active_item
    @game.item_drawer.use_active_item
    @status_shots = 3
    @status_color = Color.new(case @status
      when Items::Chili then
        0xFFFFAAAA
      when Items::Ice then
        0xFFAAAAFF
      else
        0xFFFFFFFF
    end)
  end
end
