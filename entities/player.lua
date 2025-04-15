local Player = Object:extend()

Spritesheet = {
    "sprites/chars/char9.png",
    "sprites/chars/char8.png",
    "sprites/chars/char7.png",
    "sprites/chars/char6.png"
}

AttackingSheet = {
    "sprites/attacking/char9_sword.png",
    "sprites/attacking/char8_sword.png",
    "sprites/attacking/char7_sword.png",
    "sprites/attacking/char6_sword.png"
}

function Player:new()
    --basic properties, formerly in MainState.lua

    if Character == 1 then
        self.scale = 1.25
        self.width = 64
        self.height = 64
        self.x_offset = 42
        self.y_offset = 42
    else
        self.scale = 3
        self.width = 32
        self.height = 32
        self.x_offset = 48
        self.y_offset = 64
    end

    self.animations = {
        idle = playerAnimation(love.graphics.newImage(Spritesheet[Character]), self.width, self.height, 0.5),
        attack = playerAnimation(love.graphics.newImage(AttackingSheet[Character]), self.width, self.height, 0.4)
    }

    self.animation = self.animations.idle
    self.direction = "still"

    self.type = "player"

    self.visible = true

    self.x = 480
    self.y = 320
    self.speed = 300
    self.radius = 20

    --combat properties
    self.health = 100
    self.maxHealth = 100
    self.isAttacking = false
    self.attackCooldown = 0.5
    self.attackTimer = 0
    self.attackRange = 25

    --tracks when damage is dealt to add visual effect -- want to add a robloxian oof here
    self.damageIndicator = {}  --table to store hit effects
    self.damageIndicatorDuration = 0.2  --how long hit effects last

    --can add more weapons here later
    self.equippedWeapon = "hands"
    self.weapons = {
        hands = {
            damage = {wasp = 4, honey_badger = 3, bee = 1, hive = 10, flower = 10, queenBee = 10, moth = 4, bee_eater = 5, fence = 10},
            hitChance = {wasp = 0.50, honey_badger = 0.85, bee = 0.05, hive = 1.0, flower = 1.0, queenBee = 1.0, moth = 0.50, bee_eater = 0.5, fence = 1.0}
        }
    }

    -- Collision setup
    self.collider = nil

    -- Player inventory
    self.items = { ShopTools.bucket }

    -- Current item in hand
    self.itemInHand = nil
end

function Player:update(dt)

    -- Update the attack timer
    if self.isAttacking then
        -- Set attack animation
        self.animation = self.animations.attack

        -- Calculate remaining time for the attack
        self.attackTimeLeft = self.animation.duration - self.animation.currentTime

        -- Once the animation completes, stop the attack
        if self.attackTimeLeft <= 0 then
            self.animation.currentTime = 0  -- Reset the animation to the beginning
            self.animation = self.animations.idle  -- Revert to idle animation
            self.isAttacking = false  -- Stop the attack after completion
        end
    else
        self.animation = self.animations.idle
    end

    -- Update the animation's currentTime
    self.animation.currentTime = self.animation.currentTime + dt

    -- If animation's currentTime exceeds duration, reset it
    if self.animation.currentTime >= 1 then
        self.animation.currentTime = 0  -- Reset the animation to the start
    end

    if self.collider then
        --update position based on collider
        self.x = self.collider:getX()
        self.y = self.collider:getY()
    end

    --updating attack cooldown
    if self.attackTimer > 0 then
        self.attackTimer = self.attackTimer - dt
    end

    --updating damageIndicator list
    for i = #self.damageIndicator, 1, -1 do
        local hit = self.damageIndicator[i]
        hit.timer = hit.timer - dt
        if hit.timer <= 0 then
            table.remove(self.damageIndicator, i)
        end
    end

    --player movement
    local vx = 0
    local vy = 0
    if love.keyboard.isDown("right", 'd') then
        vx = self.speed
        self.direction = DIRECTIONS[1]
    end
    if love.keyboard.isDown("left", 'a') then
        vx = self.speed * -1
        self.direction = DIRECTIONS[0]
    end
    if love.keyboard.isDown("up", 'w') then
        vy = self.speed * -1
        self.direction = DIRECTIONS[2]
    end
    if love.keyboard.isDown("down", 's') then
        vy = self.speed
        self.direction = DIRECTIONS[3]
    end

    if self.collider then
        self.collider:setLinearVelocity(vx, vy)
    end


end

function Player:keyreleased(k)
    if k == "w" or k == "a" or k == "s" or k == "d" or k == "up" or k == "left" or k == "down" or k == "right" then
        self.direction = DIRECTIONS[4]
    end
end

--distance check function
function Player:distanceTo(target)
    return math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
end

function Player:isFacing(target)

    local facing = false

    if self.direction == "left" and target.x < self.x then
        facing = true
    elseif self.direction == "right" and target.x > self.x then
        facing = true
    elseif self.direction == "up" and target.y < self.y then
        facing = true
    elseif self.direction == "down" and target.y > self.y then
        facing = true
    end

    return facing
end

--checking if target is within range
function Player:isTargetInRange(target)
    --calculate distance between the center of player and target
    local distX = math.abs(self.x - target.x)
    local distY = math.abs(self.y - target.y)

    --check if within attack range
    if target.scale >= 1 then
        return distX <= (self.attackRange + target.width * target.scale) and distY <= (self.attackRange + target.height * target.scale) and self:isFacing(target)
    else
        return distX <= (self.attackRange + target.width/2) and distY <= (self.attackRange + target.height/2) and self:isFacing(target)
    end
end

function Player:addHitFeedback(x, y)
    table.insert(self.damageIndicator, {
        x = x,
        y = y,
        timer = self.damageIndicatorDuration
    })
end

function Player:attack()
    if self.attackTimer <= 0 then
        self.isAttacking = true

        --getting mouse position
        local mx, my = love.mouse.getPosition()

        --storing and getting targets in range
        local targets = {}

        -- Checking if the target is in range
        for _, e in ipairs(Entities) do
            if e.type ~= "player" and e.type ~= "Chest" then
                if e.visible and self:isTargetInRange(e) then
                    table.insert(targets, {obj = e, type = e.type})
                    print(e.type .. " in range")
                end
            end
        end

        --applying damage to the targets in range
        if #targets > 0 then
            print("Found " .. #targets .. " targets in range")

            for _, target in ipairs(targets) do
                print("Attacking " .. target.type)

                --getting weapon damage
                local damage = self.weapons[self.equippedWeapon].damage[target.type]

                --dealing damage
                if target.obj.takeDamage then
                    target.obj:takeDamage(damage, self)
                    self:addHitFeedback(target.obj.x, target.obj.y)
                end
            end
        end

        --reset attack timer
        self.attackTimer = self.attackCooldown
    end
end

--player take damage function
function Player:takeDamage(damage, attacker)
    self.health = self.health - damage
end

function Player:draw()
    
    if self.itemInHand then
        love.graphics.draw(self.itemInHand.image, self.x - (self.itemInHand.image:getWidth()*2), self.y - self.height/2, 0, 1.5)
    end

    -- Get mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate direction based on mouse position
    local dx, dy = mouseX - self.x, mouseY - self.y
    local angle = math.atan2(dy, dx)  -- Get angle in radians

    -- Determine direction based on angle
    if angle >= -math.pi / 4 and angle <= math.pi / 4 then
        self.direction = "right"
    elseif angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
        self.direction = "down"
    elseif angle < -math.pi / 4 and angle >= -3 * math.pi / 4 then
        self.direction = "up"
    else
        self.direction = "left"
    end

    -- Assign row based on direction
    local rowMapping = {
        left = self.isAttacking and 3 or 6,
        down = 0,
        up = self.isAttacking and 1 or 2,
        right = self.isAttacking and 2 or 4
    }
    local row = rowMapping[self.direction]

    -- Determine sprite frame
    if self.direction ~= "still" then
        local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * 4) + 1 + row * 4
        if spriteNum > #self.animation.quads then
            spriteNum = #self.animation.quads  -- Use the last frame if out of bounds
        end
        love.graphics.draw(self.animation.spritesheet, self.animation.quads[spriteNum], self.x - self.x_offset, self.y - self.y_offset, 0, self.scale)
    else
        love.graphics.draw(self.animation.spritesheet, self.animation.quads[1], self.x - self.x_offset, self.y - self.y_offset, 0, self.scale)
    end

    --drawing damage effects
    for _, hit in ipairs(self.damageIndicator) do
        love.graphics.setColor(1, 0, 0, hit.timer / self.damageIndicatorDuration)
        love.graphics.circle("fill", hit.x, hit.y, 10)
    end

    love.graphics.setColor(1, 1, 1, 1)

    if DebugMode then
        Pathfinding:drawDebug()
        --draw health
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.print(string.format("Health: %d/%d", self.health, self.maxHealth), self.x - 30, self.y - 40)

        --draw attack range
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.circle("line", self.x, self.y, self.attackRange)

        --draw mouse direction
        local mx, my = love.mouse.getPosition()
        local angle = math.atan2(my - self.y, mx - self.x)
        love.graphics.setColor(0, 0.3, 1, 0.3)

        --drawing a vision cone
        local segments = 20
        love.graphics.arc("fill", self.x, self.y, self.attackRange, angle - math.pi/4, angle + math.pi/4, segments)
    end

    if DebugMode then
        --DEBUG VARIABLE PRINT FOR ENTITIES
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("ENTITY DEBUG:", 10, 10)

        love.graphics.setColor(1, 1, 1, 1)  --reset color
    end
end

function playerAnimation(image, height, width, duration)
    local animation = {}
    animation.spritesheet = image
    animation.quads = {};

    for y = 0, animation.spritesheet:getHeight() - height, height do
        for x = 0, animation.spritesheet:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, animation.spritesheet:getDimensions()))
        end
    end

    animation.duration = duration
    animation.currentTime = 0

    return animation
end

return Player
