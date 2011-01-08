class Background
  def initialize(game)
    @game = game
    @backgrounds = [
      [@game.images["background3.png"], ZOrder::Background, 5.75],
      [@game.images["background2.png"], ZOrder::Background, 3.50]
      #[@game.images["background1.png"], ZOrder::Background, 1.25]
    ]

    if rand > 0.5 then
      @backgrounds << [@game.images["foreground1.png"], ZOrder::Foreground, 0.50, 2 ** 32,
        1000 + rand(2000), nil, rand(2000)]
    end

    if rand > 0.7 then
      @backgrounds << [@game.images["foreground2.png"], ZOrder::Foreground, 0.70, 2 ** 32,
        1500 + rand(2000), 800, rand(3000), 600 - 452 + 10]
    end
  end

  def draw(view_x, view_y)
    @backgrounds.each do |(image, zorder, x_para, y_para, width, height, xoff, yoff)|
      y_para ||= x_para
      width ||= image.width
      height ||= image.height
      xoff ||= 0
      yoff ||= 0
      start_x = ((view_x.round / x_para) / width).round - 1
      start_y = ((view_y.round / y_para) / height).round - 1
      (start_x .. start_x + ((@game.main.width.to_f / width).round + 1)).each do |tx|
        (start_y .. start_y + ((@game.main.height.to_f / height).round + 1)).each do |ty|
          rx = (tx * width - view_x / x_para).round + xoff
          ry = (ty * height - view_y / y_para).round + yoff
          image.draw(rx, ry, zorder)
        end
      end
    end
  end
end
