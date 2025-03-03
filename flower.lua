Flower = Object:extend()

function Flower:new()
    self.image = love.graphics.newImage("sprites/flower.png")
    self.x = 225
    self.y = 150
end

function Flower:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
