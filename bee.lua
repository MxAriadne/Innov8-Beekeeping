Bee = Object:extend()

function Bee:new()
    self.image = love.graphics.newImage("sprites/bee.png")
    self.x = 275
    self.y = 300
    self.scale = 0.4
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 120
    self.state = "idle"
    self.hasNectar = false
end

function Bee:update(dt)
    -- empty
end


function Bee:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
end
