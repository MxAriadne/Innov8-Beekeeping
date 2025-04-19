Fence = Object:extend()

function Fence:new(x, y)
    -- Needs to be an entity so that it can be seen and attacked by others
    self.id = #Entities + 1

    -- Visual size
    self.scale = 2.5

    -- Dimensions
    self.width = 16
    self.height = 16

    -- Offset variables
    self.x_offset = 44
    self.y_offset = 44

    -- Position
    self.x, self.y = self:snapToGrid(x, y)

    -- Health variables
    self.health = 20
    self.maxHealth = 20

    -- Type check
    self.visible = true
    self.type = "fence"

    -- Collider data
    self.collider = nil

    -- Update pathfinding grid
    Pathfinding:updateGrid(self.x, self.y, true)

    -- Image holder
    self.image = love.graphics.newImage("maps/Sprout Lands - Sprites - Basic pack/Tilesets/Fences.png")
    self.quads = self:getQuads()
end

function Fence:update(dt)
    if not self.visible or self == nil then return end
    if self.collider == nil then
        self.collider = World:newRectangleCollider(self.x - (self.width*self.scale), self.y - (self.height*self.scale), self.width*self.scale, self.height*self.scale)
        self.collider:setType('static')
        self.collider:setCollisionClass('Fence')
    end
end

function Fence:snapToGrid(x, y)
    local gridSize = 42
    local snappedX = math.floor((x + self.width) / gridSize + 0.5) * gridSize
    local snappedY = math.floor((y + self.height) / gridSize + 0.5) * gridSize
    return snappedX, snappedY
end

function Fence:getAdjacent()
    local directions = {
        up    = {x = 0, y = -1},
        down  = {x = 0, y = 1},
        left  = {x = -1, y = 0},
        right = {x = 1, y = 0},
    }

    local adjacent = {}

    local gridSize = 42

    for dir, offset in pairs(directions) do
        for _, entity in ipairs(Entities) do
            if entity.type == "fence" and entity.visible then
                local dx = self.x + offset.x * gridSize
                local dy = self.y + offset.y * gridSize

                if entity.x == dx and entity.y == dy then
                    adjacent[dir] = true
                end
            end
        end
    end

    return adjacent
end

function Fence:getQuadIndex()
    local a = self:getAdjacent()

    if a.up and a.down and a.left and a.right then
        return 7 -- center
    elseif a.up and a.down and a.left then
        return 8 -- T (right open)
    elseif a.up and a.down and a.right then
        return 6 -- T (left open)
    elseif a.left and a.right and a.down then
        return 3 -- T (up open)
    elseif a.left and a.right and a.up then
        return 11 -- T (down open)
    elseif a.left and a.right then
        return 15 -- horizontal
    elseif a.up and a.down then
        return 5 -- vertical
    elseif a.right and a.down then
        return 2 -- corner top-left
    elseif a.left and a.down then
        return 4 -- corner top-right
    elseif a.right and a.up then
        return 10 -- corner bottom-left
    elseif a.left and a.up then
        return 12 -- corner bottom-right
    elseif a.up then
        return 9
    elseif a.down then
        return 1
    elseif a.left then
        return 16
    elseif a.right then
        return 14
    else
        return 13 -- single post
    end
end

function Fence:draw()
    if not self.visible or self == nil then return end

    -- Draw first quad
    local quadIndex = self:getQuadIndex()
    love.graphics.draw(self.image, self.quads[quadIndex], self.x - self.x_offset, self.y - self.y_offset, 0, self.scale)

    -- Draw debug hitbox
    if DebugMode then
        love.graphics.setColor(0.5, 0.7, 0, 0.5)
        love.graphics.rectangle("line", self.x - (self.width*self.scale), self.y - (self.height*self.scale), (self.width*self.scale), (self.height*self.scale))
        love.graphics.setColor(1, 1, 1, 1)

        --checking if target is in range
        if player:isTargetInRange(self) then
            --color hitbox green if in range
            love.graphics.setColor(0, 1, 0, 0.3)
            love.graphics.rectangle("fill", self.x - (self.width*self.scale), self.y - (self.height*self.scale), (self.width*self.scale), (self.height*self.scale))
        else
            --not in range, color yellow
            love.graphics.setColor(1, 1, 0, 0.3)
            love.graphics.rectangle("line", self.x - (self.width*self.scale), self.y - (self.height*self.scale), (self.width*self.scale), (self.height*self.scale))
        end
    end
end

function Fence:takeDamage(damage, attacker)
    self.health = self.health - damage
    if self.health <= 0 then
        self.visible = false
        self:destroy()
    end
end

function Fence:destroy()
    -- Update pathfinding grid before destroying
    Pathfinding:updateGrid(self.x, self.y, false)

    if self.collider ~= nil then
        self.collider:destroy()
        self.collider = nil
    end

    -- Find the current index of this fence in the Entities table
    for i, entity in ipairs(Entities) do
        if entity == self then
            table.remove(Entities, i)
            break
        end
    end

    self = nil
end

function Fence:getQuads()
    if self.image == nil then return end
    local grid = {}

    for y = 0, self.image:getHeight() - self.height, self.height do
        for x = 0, self.image:getWidth() - self.width, self.width do
            table.insert(grid, love.graphics.newQuad(x, y, self.width, self.height, self.image:getDimensions()))
        end
    end

    return grid
end

return Fence
