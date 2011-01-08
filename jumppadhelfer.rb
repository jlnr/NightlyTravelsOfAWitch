require 'particle'

class Jumppadhelfer < GameObject
  def update
    self.game.objects.grep(Player).each do |p|
      if (p.x - self.x).abs < 50 and p.y < self.y and p.y > self.y - 240 then
        p.vy -= 2
      end
    end
   
    true
  end
end
