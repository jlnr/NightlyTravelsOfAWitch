class Totd < SubApp
  def initialize(main, game_getter, text)
    super(main)
    @game_getter = game_getter
    @texts = Gosu::Image::from_text(main, text, Gosu::default_font_name, 22, 10, 400, :justify)
  end

  def button_up(button_id)
    case button_id
      when *Buttons[:Fire] then
        close
      when *Buttons[:Escape] then
        close
    end
  end

  def draw()
    game = @game_getter.call
    game.draw if game
    c = 0xCCFFFFFF
    @main.draw_quad(100,100,c, @main.width - 100,100,c, 100,@main.height - 100,c, @main.width - 100,@main.height - 100,c, ZOrder::MenuBack)
    @texts.draw(200, 120, 255, 1, 1, 0xEE002200)
  end 
end