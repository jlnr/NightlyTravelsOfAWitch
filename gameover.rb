class GameOver < SubApp
  def initialize(game, restart = false)
    super(game.main)
    @game = game
    @image = game.images["gameover.png"]
    @phase = 0
    @dir = 1
    @restart = restart
  end
  
  def draw()
    @game.draw unless @phase == 1
    alpha = (@phase * 255).round
    quad_color = Color.new(alpha, 255, 255, 255)
    img_alpha = ([0, @phase - 0.5].max / 0.5 * 255).round
    img_color = Color.new(img_alpha, 255, 255, 255)
    
    @game.main.draw_quad(0, 0, quad_color, 800, 0, quad_color, 0, 600, quad_color, 800, 600, quad_color, ZOrder::FadeOut)
    x = (@game.main.width - @image.width) / 2
    y = (@game.main.height - @image.height) / 2
    @image.draw(x, y, ZOrder::MenuBack, 1, 1, img_color) unless @restart

    return unless active?
  end

  def update()
    return unless active?

    if @dir == 1 then
      @game.objects.each do |obj|
        next unless obj.is_a?(Player)
        obj.look_awake
      end
    end

    speed = (@restart || @dir == -1) ? 4 : 1
    @phase = [@phase + 0.01 * @dir * speed, 1].min
    if @phase < 0 then
      close
    elsif @phase >= 1 and @restart then
      do_restart
    end
  end

  def button_up(button_id)
    return if @phase < 1

    case button_id
      when *(Buttons[:Fire] | Buttons[:Escape])
        do_restart
    end
  end

  def do_restart()
    @game.restart_level
    @dir = -1
  end
end
