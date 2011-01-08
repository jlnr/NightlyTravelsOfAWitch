class ItemDrawer  
  Space = 20
  TileWidth = 75
  TileHeight = 75
  ItemWidth = 100
  ItemHeight = 100
  
  def initialize(game, amt_hash)
    @frame = 0
    @game = game
    @left_img, @center_img, @right_img = *game.images["itemdrawer.png", TileWidth, TileHeight, true]
    @item_gfx = game.images["items.png", ItemWidth, ItemHeight, true]
    @items = (0..Items::Num - 1).to_a
    @selected_item = nil
    @items_zoom = Array.new(@items.size) { 0.6 }
    @items_count = Array.new(@items.size) { |i| amt_hash[i] || 0 }
    @active_item = nil
    @font = Font.new(@game.main, Gosu.default_font_name, 30)
  end

  def active_item()
    @active_item and @items[@active_item]
  end

  def use_active_item()
    return unless @active_item
    @items_count[@active_item] -= 1
    @active_item = nil if @items_count[@active_item] == 0
  end

  def unset_active_item()
    @active_item = nil
  end
  
  def active_item_image()
    @active_item and @item_gfx[@items[@active_item]]
  end
  
  def start_x()
    (@game.main.width - width()) / 2.0
  end

  def start_y()
    Space
  end
  
  def width()
    (@items.size + 2) * TileWidth
  end

  def height()
    TileHeight
  end

  def end_x()
    start_x + width
  end

  def end_y()
    start_y + height
  end

  alias item_start_y start_y
  alias item_end_y end_y

  def item_start_x()
    start_x + TileWidth
  end

  def item_end_x()
    end_x - TileWidth
  end
  
  def draw(screen_x, screen_y)
    x = start_x
    y = start_y

    ox = (ItemWidth - TileWidth) * 2
    oy = (ItemHeight - TileHeight)
    
    @left_img.draw(x, y, ZOrder::GUIBack)
    x += TileWidth
    @items.each_with_index do |item, index|
      @center_img.draw(x, y, ZOrder::GUIBack)

      zoom = @items_zoom[index]
      count = @items_count[index]
      of = zoom - 0.6

      active = index == @active_item
      color = Color.new(active ? 0xFFFFAAAA : 0xFFFFFFFF)
      zlevel = active ? ZOrder::GUIMoreFront : ZOrder::GUIFront
      rx = x - ox * of
      ry = y - oy * of + (active ? Math.sin(@frame / 10.0).abs * 10 : 5)
      @item_gfx[item].draw(rx, ry, zlevel, zoom, zoom, color)
      @font.draw("#{count}x", x + 5 + 2, y + TileHeight / 2 + 2, ZOrder::GUIMoreFront, 1, 1, 0xAA000000)
      @font.draw("#{count}x", x + 5, y + TileHeight / 2, ZOrder::GUIMoreFront, 1, 1, 0xFFFFFFFF)

      x += TileWidth
    end
    @right_img.draw(x, y, ZOrder::GUIBack)    
  end

  def pos_to_item_index(x, y)
    if y > item_start_y && y < item_end_y and
       x > item_start_x && x < item_end_x
    then
      [@items.size - 1, [0, (x - item_start_x).to_i / TileWidth].max].min
    end    
  end
  
  def update()
    @frame += 1
    @selected_item = pos_to_item_index(@game.main.mouse_x, @game.main.mouse_y)

    index = 0
    @items_zoom.map! do |zoom|
      rules = @selected_item == index || @active_item == index
      new_zoom = [0.6, [zoom + (rules ? 0.1 : -0.05), 1].min].max
      index += 1
      new_zoom
    end
  end

  def click(x, y)
    old_item = @active_item
    new_item = pos_to_item_index(x, y)
    if new_item and @items_count[new_item] > 0 then
      @active_item = new_item == old_item ? nil : new_item
    end
    return new_item
  end
end

