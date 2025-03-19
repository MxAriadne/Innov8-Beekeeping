Hive = Object:extend()

function Hive:new()
    self.image = love.graphics.newImage("sprites/hive.png")
    self.x = 100
    self.y = 225
    self.scale = 1
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    
    --added health and damage variables to hive
    self.health = 100  
    self.maxHealth = 100 --set to 100, might need to be balanced? feel free to change @ whoever
    self.isDamaged = false
    self.damageFlashTimer = 0
    self.damageFlashDuration = 0.2
    
    --added a honey and bee count
    self.honey = 10
    self.beeCount = 1 --set to 1 for now, for the 'default' main state hard spawned bee
end

function Hive:update(dt)
    --updating the 'health bar' when the hive is damaged
    if self.isDamaged then
        self.damageFlashTimer = self.damageFlashTimer + dt
        if self.damageFlashTimer >= self.damageFlashDuration then
            self.isDamaged = false
            self.damageFlashTimer = 0
        end
    end
end

function Hive:draw()
    --drawing 'damage' effect
    if self.isDamaged then
        love.graphics.setColor(1, 0.5, 0.5, 1)  --reddish tint when damaged
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    love.graphics.setColor(1, 1, 1, 1)
    
    --when in debug mode, triggered by '~', draw health bar and print debug info
    if debugMode then
        --drawing the health bar
        local barWidth = 50
        local barHeight = 5
        local healthPercentage = self.health / self.maxHealth
        
        --red background
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", self.x, self.y - 10, barWidth, barHeight)
        
        --green foreground
        love.graphics.setColor(0, 1, 0, 0.7)
        love.graphics.rectangle("fill", self.x, self.y - 10, barWidth * healthPercentage, barHeight)
        
        --printing hive's debug info
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Health: %d/%d\nHoney: %d\nBees: %d", self.health, self.maxHealth, self.honey, self.beeCount), self.x - 30, self.y - 40)
    end
end

--function that handles taking damage
function Hive:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
    self.isDamaged = true
    self.damageFlashTimer = 0
end
