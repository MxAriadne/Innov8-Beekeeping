GoldenDewdrops = Flower:extend()

function GoldenDewdrops:new()
    self.image = love.graphics.newImage("sprites/golden_dewdrops.png")
    self.x = 600
    self.y = 400
    self.scale = 0.3
    self.modifier = 1.5
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
end


