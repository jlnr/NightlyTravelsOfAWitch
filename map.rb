require 'gameobject'
require 'zorder'
require 'lichtschalter'
require 'Player'
require 'evilflame'
require 'Kesselhelfer'
require 'jumppadhelfer'
require 'bulbhelfer'
require 'bed'
require 'water'

class Map
  Bush = 6
  Block = 13
  WebTiles = [14, 15, 16]
  BGTiles = [nil, 1, 2, 3, 4, 5, 7, 8, 9, 10, 17, 19, 20]
  CauldronTiles = [7, 8, 9, 10]
  Water = 17
  Ice = 18
  LightBulbOff = 19
  LightBulbOn = 20

  def get(x, y)
    if x < 0 or x >= @width or y < 0 or y >= @height then
      nil
    else
      @tiles[y * @width + x]
    end
  end
  
  def set(x, y, tile)
    @tiles[y * @width + x] = tile
  end

  def initialize(game, num)
    @game = game
    @tile_gfx = game.images["Tiles.png", 50, 50, true]
    @tiles = []
    
    table = {
      'W' => lambda { |x, y| set(x, y, Water) },
      'I' => lambda { |x, y| set(x, y, Ice) },      
      'U' => lambda { |x, y| Kesselhelfer.new(game, x * 50 + 50, y * 50); set(x, y, 7); set(x + 1, y, 8); set(x, y + 1, 9); set(x + 1, y + 1, 10) }, # Cauldron TL, TR, BL, BR 
      'J' => lambda { |x, y| Jumppadhelfer.new(game, x * 50 + 50, y * 50); set(x, y, 11); set(x + 1, y, 12) },
      'B' => lambda { |x, y| set(x, y, Bush) },
      '*' => lambda { |x, y| Bed.new(game, x * 50 + 25, y * 50) }, # Bed
      'C' => lambda { |x, y| set(x, y, 5) }, # Chair
      'T' => lambda { |x, y| set(x, y, 1); set(x + 1, y, 2); set(x, y + 1, 3); set(x + 1, y + 1, 4) }, # Table TL, TR, BL, BR
      'S' => lambda { |x, y| set(x, y - 1, WebTiles[0]); set(x, y, WebTiles[1]); set(x, y + 1, WebTiles[2]); },
      '#' => lambda { |x, y| set(x, y, 0) }, # Wall grey
      'L' => lambda { |x, y| Lichtschalter.new(game, x * 50 + 25, y * 50 + 25) }, # Switch
      'X' => lambda { |x, y| Bulbhelfer.new(game, x * 50 + 25, y * 50 + 25); set(x, y, LightBulbOn) },
      'P' => lambda { |x, y| Player.new(game, x * 50 + 25, y * 50 - 51) }, # Witch herself
      'F' => lambda { |x, y| EvilFlame.new(game, x * 50 + 25 - 2, y * 50 + 50) } # Evil Flame
    }
    
    @height = 0
    File.readlines("levels/#{num}.txt").each do |line|
      line.chomp!
      
      @width ||= line.length
      @width.times do |x|
        func = table[line[x, 1]]
        if func then func.call(x, @height) end
      end
      
      @height += 1
    end
  end
  
  def draw(screen_x, screen_y)
    start_x, start_y = screen_x / 50, screen_y / 50
    offs_x, offs_y = screen_x % 50, screen_y % 50
  
    (offs_y == 0 ? 12 : 13).times do |y|
      (offs_x == 0 ? 16 : 17).times do |x|
        tile = get(x + start_x, y + start_y)
        if tile != nil then
          @tile_gfx[tile].draw(x * 50 - offs_x, y * 50 - offs_y, ZOrder::Tile)
        end
      end
    end
  end
  
  def width
    @width * 50
  end
  
  def height
    @height * 50
  end
  
  def solid?(x, y)
    x < 0 || x >= self.width || y < 0 || y >= self.height || !BGTiles.include?(get(x / 50, y / 50))
  end

  def water?(x, y)
    x >= 0 and x < self.width and y >= 0 and y < self.height and
    get(x / 50, y / 50) == Water
  end

  def do_smoke(x, y)
    30.times do
      Particle.new(@game, x + 15 - rand(31), y + 15 - rand(31), 1 - rand(3), 1 - rand(3), -1, 30, Gosu::Color.new(0xCC999999), 10, 0)
      Particle.new(@game, x + 10 - rand(21), y + 10 - rand(21), 0, 0, -1, 10 + rand(10), Gosu::Color.new(0xCC666666), 13, 0)
    end
  end
  
  def do_fire(x, y)
    tile = get(x / 50, y / 50)
    tx = x / 50
    ty = y / 50
    
    if tile == Bush or WebTiles.include?(tile) then
      set(tx, ty, nil)
      if tile == WebTiles[0] then
        set(tx, ty + 1, nil)
        set(tx, ty + 2, nil)
      end
      if tile == WebTiles[1] then
        set(tx, ty + 1, nil)
        set(tx, ty - 1, nil)
      end
      if tile == WebTiles[2] then
        set(tx, ty - 1, nil)
        set(tx, ty - 2, nil)
      end
      30.times do
        Particle.new(@game, x + 15 - rand(31), y + 15 - rand(31), 1 - rand(3), 1 - rand(3), 0, 30, Gosu::Color.new(0x99ff3300), 10, 0)
        Particle.new(@game, x + 10 - rand(21), y + 10 - rand(21), 0, 0, 0, 10 + rand(10), Gosu::Color.new(0x99ffff00), 13, 0)
      end
      do_smoke(x, y)
      return true
    end
    if get(tx, ty) == Ice then
      if get(tx, ty + 1) != nil then
        set(tx, ty, Water)
      else
        set(tx, ty, nil)
        WaterObject.new(@game, x, y + 10)
      end
      30.times do
        Particle.new(@game, x + 15 - rand(31), y + 15 - rand(31), 1 - rand(3), 1 - rand(3), 0, 30, Gosu::Color.new(0x99ff3300), 10, 0)
        Particle.new(@game, x + 10 - rand(21), y + 10 - rand(21), 0, 0, 0, 10 + rand(10), Gosu::Color.new(0x99ffff00), 13, 0)
      end
      return true
    end

    return false
  end
end
