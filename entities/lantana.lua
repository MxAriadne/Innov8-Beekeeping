CommonLantana = Flower:extend()

function CommonLantana:new()
    self.image = love.graphics.newImage("sprites/lantana.png")
    self.x = 600
    self.y = 400
    self.scale = 0.3
    self.modifier = 2
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
end


