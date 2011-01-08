class SubApp
  attr_accessor :active, :main

  def inspect()
    self.class.inspect
  end
  
  def initialize(main)
    @main = main
    @active = false
  end
  
  # Default implementations
  def update(*args) end
  def draw(*args) end
  def button_down(*args) end
  def button_up(*args) end
  def activate(*args) end
  def deactivate(*args) end

  def show()
    @main.push_app(self)
  end

  def close()
    @main.pop_app(self)
  end

  def button_down?(button)
    @main.button_down?(button) if active?
  end

  def active?()
    @active
  end
end

