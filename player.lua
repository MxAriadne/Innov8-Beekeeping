local Player = Object:extend()

function Player:new()
    --basic properties, formerly in MainState.lua
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
    self.attackRange = 50

    --tracks when damage is dealt to add visual effect -- want to add a robloxian oof here
    self.damageIndicator = {}  --table to store hit effects
    self.damageIndicatorDuration = 0.2  --how long hit effects last

    --can add more weapons here later
    self.equippedWeapon = "hands"
    self.weapons = {
        hands = {
            damage = {wasp = 4, honeybadger = 3, bee = 5, hive = 10},
            hitChance = {wasp = 0.50, honeybadger = 0.85, bee = 0.70, hive = 1.0}
        }
    }

    --collision setup
    self.collider = nil
end

function Player:update(dt)
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
    end
    if love.keyboard.isDown("left", 'a') then
        vx = self.speed * -1
    end
    if love.keyboard.isDown("up", 'w') then
        vy = self.speed * -1
    end
    if love.keyboard.isDown("down", 's') then
        vy = self.speed
    end

    if self.collider then
        self.collider:setLinearVelocity(vx, vy)
    end
end

--distance check function
function Player:distanceTo(target)
    return math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
end

--checking if target is within range
function Player:isTargetInRange(target)
    --player x and y
    local pCenterX = self.x
    local pCenterY = self.y

    --getting the center of the target
    local tCenterX = target.x + (target.width or 40)/2
    local tCenterY = target.y + (target.height or 40)/2

    local tWidth = target.width or 40
    local tHeight = target.height or 40

    if target.is_bee then tWidth, tHeight = 40, 40 end
    if target.is_hive then tWidth, tHeight = 80, 80 end

    --calculate distance between the center of player and target
    local distX = math.abs(pCenterX - tCenterX)
    local distY = math.abs(pCenterY - tCenterY)

    --check if within attack range
    return distX <= (self.attackRange + tWidth/2) and distY <= (self.attackRange + tHeight/2)
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

        --checking if the target is in range
        if wasp and wasp.visible and self:isTargetInRange(wasp) then
            table.insert(targets, {obj = wasp, type = "wasp"})
            print("Wasp in range")
        end

        if honeybadger and honeybadger.visible and self:isTargetInRange(honeybadger) then
            table.insert(targets, {obj = honeybadger, type = "honeybadger"})
            print("HoneyBadger in range")
        end

        if bee and bee.visible and self:isTargetInRange(bee) then
            table.insert(targets, {obj = bee, type = "bee"})
            print("Bee in range")
        end

        if hive and hive.visible and self:isTargetInRange(hive) then
            table.insert(targets, {obj = hive, type = "hive"})
            print("Hive in range")
        end

        --applying damage to the targets in range
        if #targets > 0 then
            print("Found " .. #targets .. " targets in range")

            for _, target in ipairs(targets) do
                print("Attacking " .. target.type)

                -- not dealing damage to fleeing enemies
                if target.obj.state and (target.obj.state == "retreating" or target.obj.state == "fleeing") then
                    goto continue
                end

                --getting weapon damage
                local damage = self.weapons[self.equippedWeapon].damage[target.type]

                --dealing damage
                if target.obj.takeDamage then
                    target.obj:takeDamage(damage, self)
                    self:addHitFeedback(target.obj.x, target.obj.y)
                end

                ::continue::
            end
        end

        --reset attack timer
        self.attackTimer = self.attackCooldown
    end
end

--player take damage function
function Player:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
end

function Player:draw()
    --player draw, formerly in MainState.lua
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("line", self.x, self.y, self.radius)

    --drawing damage effects
    for _, hit in ipairs(self.damageIndicator) do
        love.graphics.setColor(1, 0, 0, hit.timer / self.damageIndicatorDuration)
        love.graphics.circle("fill", hit.x, hit.y, 20)
    end

    love.graphics.setColor(1, 1, 1, 1)

    if debugMode then
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
        local angleStep = math.pi/2 / segments
        love.graphics.arc("fill", self.x, self.y, self.attackRange, angle - math.pi/4, angle + math.pi/4, segments)

        --draw entity hitboxes
        local targets = {
            {obj = wasp, type = "wasp", color = {1, 1, 0}},
            {obj = honeybadger, type = "honeybadger", color = {0.7, 0.4, 0}},
            {obj = bee, type = "bee", color = {1, 0.8, 0}},
            {obj = hive, type = "hive", color = {0.8, 0.6, 0.2}}
        }

        for _, target in ipairs(targets) do
            if target.obj and target.obj.visible then
                --drawing the hitboxes
                love.graphics.setColor(target.color[1], target.color[2], target.color[3], 0.7)

                --getting size
                local width = target.obj.width
                local height = target.obj.height

                --drawing rectange shape centered around png
                love.graphics.rectangle("line", target.obj.x - width/2, target.obj.y - height/2, width, height)

                --checking if target is in range
                if self:isTargetInRange(target.obj) then
                    --color hitbox green if in range
                    love.graphics.setColor(0, 1, 0, 0.3)
                    love.graphics.rectangle("fill", target.obj.x - width/2, target.obj.y - height/2, width, height)
                else
                    --not in range, color yellow
                    love.graphics.setColor(1, 1, 0, 0.3)
                    love.graphics.rectangle("line", target.obj.x - width/2, target.obj.y - height/2, width, height)
                end
            end
        end
    end

    if debugMode then
        --DEBUG VARIABLE PRINT FOR ENTITIES
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("ENTITY DEBUG:", 10, 10)

        if wasp then
            love.graphics.print("Wasp: x=" .. math.floor(wasp.x) .. " y=" .. math.floor(wasp.y) .. " Health=" .. (wasp.health or "N/A"), 10, 30)
        end

        if bee then
            love.graphics.print("Bee: x=" .. math.floor(bee.x) .. " y=" .. math.floor(bee.y) .. " Health=" .. (bee.health or "N/A"), 10, 50)
        end

        if honeybadger then
            love.graphics.print("HoneyBadger: x=" .. math.floor(honeybadger.x) .. " y=" .. math.floor(honeybadger.y) .. " Health=" .. (honeybadger.health or "N/A"), 10, 70)
        end

        if hive then
            love.graphics.print("Hive: x=" .. math.floor(hive.x) .. " y=" .. math.floor(hive.y) .. " Health=" .. (hive.health or "N/A") .." Bees: " .. (hive.beeCount or 0), 10, 90)
        end

        love.graphics.setColor(1, 1, 1, 1)  --reset color
    end
end

return Player
