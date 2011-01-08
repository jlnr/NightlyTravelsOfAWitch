class Password < SubApp
  ItemWidth = ItemDrawer::ItemWidth
  ItemHeight = ItemDrawer::ItemHeight
  
  def initialize(main, game_getter, game_creator, show_for = nil)
    super(main)
    @game_getter = game_getter
    @game_creator = game_creator
    @selection = 0
    @password_gfx = Image.load_tiles(main, "media/items.png", ItemWidth, ItemHeight, false)
    @show_for = show_for
    @password = if show_for then
      level_password(show_for)
    else
      Array.new(PasswordLength) { 0 }
    end
    @error = 0
    @errorsound = Gosu::Sample.new(main, "sounds/brrrrb.ogg") 

    text = show_for ? "Secret password for level #{show_for}\n(Write it down!)" :
      "To continue play enter\nthe secret level password below:"
    @text_img = Image.from_text(main, text, Gosu.default_font_name, 70, 0, main.width - 20, :center)
  end

  def level_password(level)
    Digest::SHA1.hexdigest("gosu secret. KRUEPTO TAIM." + level.to_s).to_i(16).to_s(@password_gfx.size)[0, PasswordLength].split(//).map { |x| x.to_i }
  end
  
  def width()
    ItemWidth * PasswordLength
  end

  def height()
    ItemHeight
  end
  
  def button_up(button_id)
    if @show_for != nil then
      case button_id
        when *Buttons[:Fire] | Buttons[:Escape] then
          close
      end
    else
      case button_id
        when Button::KbUp, Button::GpUp, Button::MsWheelUp then
          @password[@selection] = (@password[@selection] + 1) % @password_gfx.size
        when Button::KbDown, Button::GpDown, Button::MsWheelDown then
          @password[@selection] = (@password[@selection] - 1) % @password_gfx.size
        when Button::MsLeft then
          @selection += 1
          if @selection == PasswordLength then
            @selection = 0
            submit
          end
        when Button::MsRight, Button::KbLeft, Button::GpLeft then
          @selection = (@selection - 1) % PasswordLength
        when Button::KbRight, Button::GpRight then
          @selection = (@selection + 1) % PasswordLength
        when *Buttons[:Fire] then
          submit
        when *Buttons[:Escape] then
          close
      end
    end
  end

  def submit()
    success = false
    (1 .. LevelCount).each do |level|
      if level_password(level) == @password then
        game = @game_creator.call(level)
        close
        game.show
        success = true
      end
    end
    if not success
      @errorsound.play
      @error += 1
      if @error == 3 then
        close
      end
    end
  end

  def show()
    super
    @error = 0
  end

  def draw()
    game = @game_getter.call
    game.draw if game

    c = 0xAA000000
    @main.draw_quad(0,0,c, @main.width,0,c, 0,@main.height,c, @main.width,@main.height,c, ZOrder::MenuBack)

    @text_img.draw(10, 10, ZOrder::MenuFront)
      
    x = (@main.width - width) / 2.0
    y = (@main.height - height) / 2.0
    @password.each_with_index do |pwd, index|
      if index == @selection and @show_for == nil then
        c = 0xFF9A0016
        @main.draw_quad(x,y,c, x+ItemWidth,y,c,
          x,y+ItemHeight,c, x+ItemWidth,y+ItemHeight,c,
          ZOrder::MenuBack)
      end
      @password_gfx[pwd].draw(x, y, ZOrder::MenuFront)
      x += ItemWidth
    end
  end
end
