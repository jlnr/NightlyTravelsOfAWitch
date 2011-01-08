class EvilFlame < MovingObject
  def initialize(*args)
    super(*args)
    @vertices = [[0, -5], [-10, -10], [+10, -10]]
    @dir = rand > 0.5 ? -1 : +1
    @destroyed = false
  end

  def destroy()
    @destroyed = true
  end
  
  def in_water?(offs_x = 0, offs_y = 0)
    @vertices.any? { |pt| @game.map.water?(self.x + pt[0] + offs_x, self.y + pt[1] + offs_y) } or
    @game.objects.grep(WaterObject).any? do |water|
      Gosu.distance(water.x, water.y, @x, @y) < 40
    end
  end

  def draw(view_x, view_y)
    #@game.images["lichtschalter.png"].draw_rot(@x - view_x, @y - view_y, ZOrder::MenuFront)
  end
  
  def update()
    return false if @destroyed
    
    if rand(3) == 0 then
      Particle.new(self.game, self.x - 30 + rand(50) + 10 * @dir, self.y - 20, 1 - rand(2), -1 + rand(1), 0, 42, Color.new(255, 0xCC, 0xBB, 0), 13, 2)
    else
      Particle.new(self.game, self.x - 30 + rand(50) + 10 * @dir, self.y - 20, 1 - rand(2), -2 + rand(3), 0, 42, Color.new(255, 0xC0, 50, 0), 9, 2)
    end

    if rand(50) == 0 then
      nearest_player = @game.objects.grep(Player).sort_by do |plr|
        Gosu.distance(plr.x, plr.y, @x, @y)
      end.first
      bias = if nearest_player then
               nearest_player.x < @x ? -1 : +1
             else
               0
             end
      @dir = rand > 0.5 + 0.2 * bias ? -1 : +1
    end

    blocked = !1.times { if blocked?(@dir, 0) then break else self.x += @dir end }

    @game.objects.grep(Player).each do |player|
      if Gosu.distance(player.x, player.y, @x + 30 * @dir, @y - 100) < 20 then
        player.unsleep(0.5)
        @game.map.do_smoke(player.x, player.y)
      end
    end

    @game.map.do_fire(@x + 20 * @dir, @y - 20)
    
    @dir *= -1 if blocked
    
    fall
    super
    
    return !in_water?
  end
end
