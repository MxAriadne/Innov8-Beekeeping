Wasp = Object:extend()

function Wasp:new()
    self.image = love.graphics.newImage("sprites/wasp.png")
    self.x = 700
    self.y = 250
    self.scale = 0.08
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 100
    self.state = "idle"
end

function Wasp:findPath(targetX, targetY)
    -- empty
end

function Wasp:targetHive()
    -- empty
end

function Wasp:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
end
