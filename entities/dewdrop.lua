GoldenDewdrops = Flower:extend()

function GoldenDewdrops:new(x, y)
    self.id = #Entities + 1
    self.image = love.graphics.newImage("sprites/golden_dewdrops.png")
    self.x = x or 600
    self.y = y or 400
    self.scale = 0.3
    self.modifier = 1.5
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.type = "flower"
    self.onCooldown = false
    self.harvestCooldown = 6
    self.harvestTimer = 0
end


