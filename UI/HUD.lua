-- Main State HUD implementation
-- Author: Amelia Reiss

local HUD = {}
local tileSize = 32
local itemSize = tileSize * 1.5 -- 1.5 times dimension of tile
local ShopItems = require "ShopItems"

function HUD:load()
    --set colors
    self.colors = {
        text = {.5, 0, .5, 1},
        money = {1, 0.9, 0.2, 1},
        buildMode = {0.5, 0.5, 1, 1}
    }

    -- images of items in hotbar will be attributed to each tool
    self.hotbar = {} -- Outline of hotbar
    self.hotbarSize = 4 -- Number of items displayed in hotbar
end

function HUD:update(dt)
    self.canvases = {} -- Canvases for current items

    -- Check if player has items in inventory
    if player and player.items then
        -- Create canvas for each item
        for i, item in ipairs(player.items) do
            local canvas = love.graphics.newCanvas(itemSize, itemSize)
            love.graphics.setCanvas(canvas) -- Switch drawing to canvas
            love.graphics.clear(0, 0, 0, 0) -- Make new canvas transparent
            love.graphics.setColor(1,1,1) -- Set color back to default
            love.graphics.draw(item.image, 0, 0, 0,
                                canvas:getWidth() / item.image:getWidth(),
                                canvas:getHeight() / item.image:getHeight()) -- Draw image onto canvas
            love.graphics.setCanvas() -- Swtich back to screen
            table.insert(self.canvases, canvas) -- Add canvas to table
        end
    end
end

function HUD:draw()
    love.graphics.setFont(XSfont) --- BY THE WAY THIS FIXES THE BUG WHERE THE HUD FONT IS SUDDENLY BIGGER UPON LOADING INTO MAIN STATE --- IT RESETS THE FONT SIZE !!!
    --draw money
    love.graphics.setColor(self.colors.money)
    love.graphics.print("Money: " .. PlayerMoney .. " KSh ", 800, 60)

    --draw build mode if active
    if CurrentBuildMode then
        love.graphics.setColor(self.colors.buildMode)
        local buildModeText = "Build Mode: " .. CurrentBuildMode
        love.graphics.print(buildModeText, 800, 80)
        love.graphics.print("Right-click to place", 800, 100)
    end


    --print controls
    love.graphics.setColor(self.colors.text)

    local controlsText = {
        "Controls:",
        "Left Click - Attack",
        "Right Click - Use",
        "Space - Advance Day"
    }

    for i, line in ipairs(controlsText) do
        love.graphics.print(line, 800, 200 - (#controlsText - i + 1) * (12 + 2) - 10)
    end
    
    --color reset
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(love.graphics.newImage("sprites/sign.png"), 825, 25, 0, 1.5)

    local text = PlayerMoney .. " KSh"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    
    local left = 832
    local right = 915
    local centerX = (left + right) / 2
    
    love.graphics.print(text, centerX - textWidth / 2, 75)

    -- Determine position and size of hotbar / item image
    local hotbarX = GameConfig.windowW - itemSize
    local hotbarY = GameConfig.windowH / 2 - ((self.hotbarSize / 2) * itemSize)

    -- Draw empty hotbar
    for i = 0, self.hotbarSize do
        local slot = love.graphics.rectangle("line", hotbarX, hotbarY + i * itemSize, itemSize, itemSize)
        table.insert(self.hotbar, slot)
    end

    -- If canvases for items were created, draw them in hotbar
    if self.canvases and #self.canvases > 0 then
        for i, canvas in ipairs(self.canvases) do
            love.graphics.draw(canvas, hotbarX, hotbarY + (i-1) * itemSize)
        end
    end
end

return HUD
