class MovingObject < GameObject
  attr_accessor :vy, :vertices
  
  # vertices ist ein Array aus zweielementigen Arrays, die die Punkte angeben, an denen fuer ein Objekt
  # die Kollisionsabfrage mit der Karte ueberprueft wird (relativ zu x/y)
  
  def initialize(game, x, y)
    super(game, x, y)
    @vy = 0
    @vertices = []
  end
  
  def blocked?(offs_x, offs_y)
    # an x+offs_x und y+offs_y ist dann solide, wenn ein Vertex da nicht hinpassen wuerde
    # - um zu pruefen ob das Objekt auf dem Boden liegt also zB blocked?(0, 1)
    @vertices.any? { |pt| @game.map.solid?(self.x + pt[0] + offs_x, self.y + pt[1] + offs_y) }
  end
  
  def fall
    @vy += 1
  end

  def touch_ground
    # wird aufgerufen wenn Objekt an Decke oder Boden stoesst, kann ueberschrieben werden etc
    @vy = 0
  end
  
  def update
    if @vy < 0 then
      (-@vy).times do
        if blocked?(0, -1) then
          self.touch_ground
          break
        else
          self.y -= 1
        end
      end
    else
      @vy.times do
        if blocked?(0, +1) then
          self.touch_ground
          break
        else
          self.y += 1
        end
      end
    end
  
    true
  end
end
