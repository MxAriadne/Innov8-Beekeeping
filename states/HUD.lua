-- Main State HUD implementation
-- Author: Amelia Reiss

local HUD = {}

-- Variables for tables/attributes not yet defined
-- example of player.items
local items = { {name = "item1", image = love.graphics.newImage("logo.png")}, 
                {name = "item2", image = love.graphics.newImage("logo.png")},
                }

function HUD:load()
    -- images of items in hotbar will be attributed to each tool
    self.hotbar = {} -- Outline of hotbar

end

function HUD:draw()
    -- Determine position and size of hotbar / item image
    local hotbarSize = 10 -- Number of items displayed in hotbar
    local itemSize = 32 -- 2 times tile height
    local hotbarX = GameConfig.windowW / 2 - ((hotbarSize / 2) * itemSize)
    local hotbarY = GameConfig.windowH

    -- Draw empty hotbar
    for i = 0, self.hotbarSize do
        table.insert(self.hotbar, love.graphics.rectangle("line", hotbarX + i * itemSize, hotbarY))
    end

    -- If player has tools, draw the images
    -- *assume image is variable of tool table*
    if items then
        for i, item in ipairs(items) do
            love.graphics.draw(item)
        end
    end
end

return HUD