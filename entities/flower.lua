Flower = Object:extend()

function Flower:new()
    self.image = love.graphics.newImage("sprites/orchid.png")
    self.x = 600
    self.y = 400
    self.scale = 0.3
    self.modifier = 1
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
end

function Flower:draw()
    if not self.visible then return end
    love.graphics.draw(self.image, self.x-20, self.y-28, 0, self.scale, self.scale)
end

function Flower:takeDamage(damage, attacker)
    self.health = math.max(0, self.health - damage)
    if self.health <= 0 then
        self.visible = false
        table.remove(Flowers, Flower[self])
    end
end

