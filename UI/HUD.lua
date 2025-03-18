-- Main State HUD implementation
-- Author: Amelia Reiss

local HUD = {}
local tileSize = 32

-- Variables for tables/attributes not yet defined
-- example of player.items
local items = { {name = "item1", image = love.graphics.newImage("logo.png")}, 
                {name = "item2", image = love.graphics.newImage("logo.png")},
                }

function HUD:load()
    -- images of items in hotbar will be attributed to each tool
    self.hotbar = {} -- Outline of hotbar
    self.hotbarSize = 10 -- Number of items displayed in hotbar

end

function HUD:draw()
    -- Determine position and size of hotbar / item image
    local itemSize = tileSize * 1.5 -- 1.5 times dimension of tile
    local hotbarX = GameConfig.windowW / 2 - ((self.hotbarSize / 2) * itemSize)
    local hotbarY = GameConfig.windowH - itemSize - tileSize

    -- Draw empty hotbar
    for i = 0, self.hotbarSize do
        local slot = love.graphics.rectangle("line", hotbarX + i * itemSize, hotbarY, itemSize, itemSize)
        table.insert(self.hotbar, slot)
    end

    -- If player has tools, draw the images
    -- *assume image is variable of tool table*
    if items then
        for i, item in ipairs(items) do
            love.graphics.draw(item.image, hotbarX + i * itemSize, hotbarY, 0, .5, .5)
        end
    end
end

return HUD