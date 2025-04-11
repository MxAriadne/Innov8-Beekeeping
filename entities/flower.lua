Flower = Object:extend()

function Flower:new(x, y)
    self.id = #Entities + 1
    self.image = love.graphics.newImage("sprites/orchid.png")
    self.x = x or 600
    self.y = y or 400
    self.scale = 0.3
    self.modifier = 1
    self.visible = true
    self.health = 20
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.type = "flower"
    self.onCooldown = false
    self.harvestCooldown = 3
    self.harvestTimer = 0
end

function Flower:draw()
    if not self.visible or self == nil then return end
    love.graphics.draw(self.image, self.x-20, self.y-28, 0, self.scale, self.scale)
end

function Flower:takeDamage(damage, attacker)
    self.health = math.max(0, self.health - damage)
    if self.health <= 0 then
        self.visible = false
        -- Find the current index of this flower in the Entities table
        for i, entity in ipairs(Entities) do
            if entity == self then
                table.remove(Entities, i)
                break
            end
        end
        self = nil
    end
end

function Flower:update(dt)
    if not self.visible or self == nil then return end

    if self.onCooldown then
        self.harvestTimer = self.harvestTimer + dt
        if self.harvestTimer >= self.harvestCooldown then
            self.onCooldown = false
            self.harvestTimer = 0
        end
    end
end

