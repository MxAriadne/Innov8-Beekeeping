CommonLantana = Flower:extend()

function CommonLantana:new(x, y)
    self.id = #Entities + 1
    self.image = love.graphics.newImage("sprites/lantana.png")
    self.x = x or 600
    self.y = y or 400
    self.scale = 0.3
    self.modifier = 2
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.type = "flower"
    self.onCooldown = false
    self.harvestCooldown = 9
    self.harvestTimer = 0
end


