Hive = Object:extend()

function Hive:new()
    self.image = love.graphics.newImage("sprites/hive.png")
    self.x = 420
    self.y = 315
    self.scale = 0.6 
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.honey = 10
    self.beeCount = 1 --set to 1 for now, for the 'default' main state hard spawned bee
    self.maxBeeCount = 5  --maximum number of bees - could be level dependent? or might remove later?

    --hive health variables
    self.health = 100
    self.maxHealth = 100
    
    --type check flag
    self.is_hive = true
    self.visible = true
    
    --taking damage effect
    self.flashTimer = 0
    self.flashDuration = 0.2
end

function Hive:update(dt)
    --update damage flash effect
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.flashTimer = 0
        end
    end
end

function Hive:draw()
    --draw with damage flash effect if being damaged
    if self.flashTimer > 0 then
        love.graphics.setColor(1, 0.5, 0.5, 1)  --reddish tint
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    --drawing hive on the center of its png
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)
    
    if debugMode then
        --drawing the health bar
        local barWidth = 50
        local barHeight = 5
        local healthPercentage = self.health / self.maxHealth
        
        --red background
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10 - self.height/2, barWidth, barHeight)
        
        --green foreground
        love.graphics.setColor(0, 1, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10 - self.height/2, barWidth * healthPercentage, barHeight)
        
        --printing hive's debug info
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Health: %d/%d\nHoney: %d\nBees: %d", self.health, self.maxHealth, self.honey, self.beeCount), self.x - 30, self.y - 40 - self.height/2)
    end
end

--function that handles taking damage
function Hive:takeDamage(damage, attacker)
    self.health = math.max(0, self.health - damage)
    self.flashTimer = self.flashDuration
    --print("Hive took " .. damage .. " damage, health now: " .. self.health)
end

return Hive