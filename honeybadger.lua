HoneyBadger = Object:extend()

function HoneyBadger:new()
    self.image = love.graphics.newImage("sprites/honey-badger.png")
    self.x = 425
    self.y = 150
    self.scale = 0.3
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
end

function HoneyBadger:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
end

function HoneyBadger:update(dt)
    -- empty method
end
