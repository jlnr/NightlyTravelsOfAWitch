$LOAD_PATH.unshift('.')

require 'bundler/setup'
require 'gosu'
require 'zorder'
require 'items'
require 'subapp'
require 'menu'
require 'game'
require 'password'
require 'levelstats'
require 'digest/sha1'

include Gosu

Buttons = {
  :Fire => [
    Button::KbReturn,
    Button::KbEnter,
    Button::GpButton0,
    Button::MsLeft
  ],
  :Escape => [
    Button::KbEscape,
    Button::GpButton4
  ]
}

PasswordLength = 6

class Gosu::Color
  def mix(other, b = 0.5)
    c = 1.0 - b
    Color.new(
      (self.alpha * b + other.alpha * c).to_i,
      (self.red * b + other.red * c).to_i,
      (self.green * b + other.green * c).to_i,
      (self.blue * b + other.blue * c).to_i
    )
  end
end

class MainApp < Window
  attr_reader :apps
  
  def initialize(*args)
    @apps = Array.new
    super(*args)
  end

  def push_app(app)
    @apps << app
    app.active = true
    app.activate
  end

  def pop_app(pop_app)
    app = nil
    if @apps.last == pop_app then
      app = @apps.pop
      begin
        app.deactivate
      ensure
        app.active = false
      end
    else
      @apps.reject! { |x| app = x if pop_app == x }
    end
    @apps.last.activate if @apps.size > 0
  end

  def dispatch(method, *args)
    if @apps.size == 0 then
      close
    else
      @apps.last.send(method, *args)
    end
  end
  
  [:draw, :update, :button_down, :button_up].each do |method|
    define_method(method) do |*args|
      dispatch(method, *args)
    end
  end
  
  alias :old_button_down :button_down
  def button_down(button_id)
    case button_id
      when Button::MsWheelUp, Button::MsWheelDown then
        button_up(button_id)
      else
        old_button_down(button_id)
    end
  end

  alias :old_button_up :button_up
  def button_up(button_id)
    case button_id
      when Button::MsLeft, Button::MsMiddle, Button::MsRight then
        if mouse_x > 0 and mouse_y > 0 and mouse_x < width and mouse_y < height then
          old_button_up(button_id)
        end
      else
        old_button_up(button_id)
    end
  end
end

game = nil
main = MainApp.new(800, 600, false, 20)
main.caption = "Nightly Travels of a Witch"
menu_font = Font.new(main, Gosu.default_font_name, 80 * main.height / 240)
#options_menu = Menu.new(main, menu_font, lambda { game }, [
#  ["Screen Resolution", lambda { }],
#  ["Gore", lambda { }],
#  ["Bush", lambda { }],
#  ["Back", lambda { close }]
#])
password = Password.new(main, lambda { game }, lambda { |i| game = Game.new(main, i) })
main_menu = Menu.new(main, menu_font, lambda { game }, [
  ["Continue Game", lambda { game.show }, lambda { game != nil }],
  ["New Game", lambda { game = Game.new(main, (ARGV[0] || 1).to_i); game.show }], # FIXME, REMOVE CHEAT
  ["Password", lambda { password.show }],
#  ["Options", lambda { options_menu.show }],
  ["Exit", lambda { close }]
])
main_menu.show
main.show

