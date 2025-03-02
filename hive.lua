Hive = Object:extend()

function Hive:new()
    self.image = love.graphics.newImage("sprites/hive.png")
    self.x = 125
    self.y = 350
end

function Hive:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
