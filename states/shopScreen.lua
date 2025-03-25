-- Shop screen implementation
-- Author: Amelia Reiss

local shopScreen = {}

-- Import relevant files
local items = require "items"

-- Calculate dimensions and positioning of each canvas
local itemCanvasW = 10
local itemCanvasH = 10
local itemCanvasX = 0
local itemCanvasY = 0

-- Function to load UI elements for shop screen
function shopScreen:enter()
    -- Check which items are available for purchase/browsing
    -- Get available items for purchase
    local items = items

    -- Ensure there are items to draw
    if items then

        -- Create canvases for available items
        self.canvases = {}
        for _, item in ipairs(items) do
            local canvas = love.graphics.newCanvas(itemCanvasW, itemCanvasH)
            love.graphics.setCanvas(canvas) -- Switch drawing to canvas
            
            -- Add image
            -- Add description
            -- Add price
            -- Add buy button

            love.graphics.setCanvas() -- Swtich back to screen

            table.insert(self.canvases, canvas) -- Add canvas to table
        end        
    else
        -- Create text to display no available items
    end
    
    -- Get user honey/currency count

    -- Load scroll buttons

end

-- Function to draw screen
function shopScreen:draw()
    


end

return shopScreen