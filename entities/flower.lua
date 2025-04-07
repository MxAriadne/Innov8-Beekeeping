Flower = Object:extend()

function Flower:new()
    self.image = love.graphics.newImage("sprites/orchid.png")
    self.x = 600
    self.y = 400
    self.scale = 0.1
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
end

function Flower:draw()
    love.graphics.draw(self.image, self.x, self.y, self.scale, self.scale)
end
