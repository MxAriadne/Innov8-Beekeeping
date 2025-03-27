-- Main State HUD implementation
-- Author: Amelia Reiss

local HUD = {}
local tileSize = 32
local itemSize = tileSize * 1.5 -- 1.5 times dimension of tile
local items = require "items"

function HUD:load()
    -- images of items in hotbar will be attributed to each tool
    self.hotbar = {} -- Outline of hotbar
    self.hotbarSize = 10 -- Number of items displayed in hotbar
    self.canvases = {} -- Canvases for current items

    -- Check if player has items in hotbar
    if items then
        -- Create canvas for each item
        for i, item in ipairs(items) do
            local canvas = love.graphics.newCanvas(itemSize, itemSize)
            love.graphics.setCanvas(canvas) -- Switch drawing to canvas
            love.graphics.clear(0, 0, 0, 0) -- Make new canvas transparent
            love.graphics.draw(item.image, 0, 0, 0,
                                canvas:getWidth() / item.image:getWidth(),
                                canvas:getHeight() / item.image:getHeight()) -- Draw image onto canvas
            love.graphics.setCanvas() -- Swtich back to screen

            table.insert(self.canvases, canvas) -- Add canvas to table
        end
    end

    --set colors
    self.colors = {
        text = {.5, 0, .5, 1},
        money = {1, 0.9, 0.2, 1},
        buildMode = {0.5, 0.5, 1, 1}
    }

end

function HUD:draw()
    --draw money
    love.graphics.setColor(self.colors.money)
    love.graphics.print("Money: $" .. playerMoney, 800, 60)

    --draw build mode if active
    if currentBuildMode then
        love.graphics.setColor(self.colors.buildMode)
        local buildModeText = "Build Mode: " .. currentBuildMode
        love.graphics.print(buildModeText, 800, 80)
        love.graphics.print("Right-click to place", 800, 100)
    end


    --print controls
    love.graphics.setColor(self.colors.text)
    local controlsText = {
        "Controls:",
        "F - Buy Hive ($" .. hiveCost .. ")",
        "G - Buy Bee ($" .. beeCost .. ")",
        "H - Buy Flower ($" .. flowerCost .. ")",
        "Left Click - Attack",
        "Space - Advance Day",
        "` - Toggle Debug"
    }

    for i, line in ipairs(controlsText) do
        love.graphics.print(line, 800, 250 - (#controlsText - i + 1) * (12 + 2) - 10)
    end

    --color reset
    love.graphics.setColor(1, 1, 1, 1)

    -- Determine position and size of hotbar / item image
    local hotbarX = GameConfig.windowW / 2 - ((self.hotbarSize / 2) * itemSize)
    local hotbarY = GameConfig.windowH - itemSize - tileSize

    -- Draw empty hotbar
    for i = 0, self.hotbarSize do
        local slot = love.graphics.rectangle("line", hotbarX + i * itemSize, hotbarY, itemSize, itemSize)
        table.insert(self.hotbar, slot)
    end

    -- If canvases for items were created, draw them in hotbar
    if self.canvases then
        love.graphics.setBlendMode("alpha")
        for i, canvas in ipairs(self.canvases) do
            love.graphics.draw(canvas, hotbarX + (i-1) * itemSize, hotbarY)
        end
    end
end

return HUD
