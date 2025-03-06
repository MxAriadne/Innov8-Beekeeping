Hive = Object:extend()

function Hive:new()
    self.image = love.graphics.newImage("sprites/hive.png")
    self.x = 425
    self.y = 350
    self.scale = 1
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.nectar = 0
end

function Hive:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
end

--for when a bee brings in nectar that has been foraged
function Hive:receiveNectar()
    self.nectar = self.nectar + 1
end
