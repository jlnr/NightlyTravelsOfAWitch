class Menu < SubApp
  attr_accessor :entries

  def initialize(main, font, game_getter, entries)
    super(main)
    @font = font
    @entries = entries
    @game_getter = game_getter
  end
  
  def activate()
    @selection = 0
    @frame = 0
    @last_frame = 0

    @visible_entries = @entries.find_all do |(text, action, cond)|
      cond.nil? || instance_eval(&cond)
    end
  end
  
  def button_up(button_id)
    case button_id
      when Button::KbUp, Button::GpUp, Button::MsWheelUp then
        @selection = (@selection - 1) % @visible_entries.size
      when Button::KbDown, Button::GpDown, Button::MsWheelDown then
        @selection = (@selection + 1) % @visible_entries.size
      when *Buttons[:Fire] then
        text, action, cond = *@visible_entries[@selection]
        instance_eval(&action)
      when *Buttons[:Escape] then
        game = @game_getter.call()
        game.show if game
    end
  end

  def draw()
    game = @game_getter.call
    game.draw if game

    c = 0xAA000000
    @main.draw_quad(0,0,c, @main.width,0,c, 0,@main.height,c, @main.width,@main.height,c, ZOrder::MenuBack)
    
    @visible_entries.each_with_index do |(text, action, cond), index|
      ry = (index + 1.0) / @visible_entries.size
      space_height = @main.height / 3.0
      y = ry * (@main.height - space_height) + space_height / 4
      is_active = (index == @selection)
      scale_y = is_active ? (Math.sin(@frame += 0.1) / 2.0 + 1.5) : 1.0
      color = is_active ? 0xFFFFD579 : 0xFFFFFFFF
      if is_active
        width = text.size * 50
        x1, x2 = (@main.width - width) / 2, (@main.width + width) / 2
        y1, y2 = y - @font.height / 5.5, y + @font.height / 5.5
        oxt = Math.sin(@frame) * 10
        oxb = Math.sin(@frame) * -5
        c = 0xFF9A0016
        @main.draw_quad(x1+oxt,y1,c, x2-oxt,y1,c, x1+oxb,y2,c, x2-oxb,y2,c, ZOrder::MenuBack)
      end
      @font.draw_rel(text, @main.width / 2, y, ZOrder::MenuFront, 0.5, 0.5, 0.5, scale_y / 2, color)
    end
  end
end

