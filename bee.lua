Bee = Object:extend()

function Bee:new()
    self.image = love.graphics.newImage("bee.png")
    self.x = 325
    self.y = 450
end


function Bee:draw()
    love.graphics.draw(self.image, self.x, self.y)
end