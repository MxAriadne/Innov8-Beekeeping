-- Load Save Files Implementation
-- Author: Amelia Reiss

local gameSaves = {}

-- Import required modules
local button = require "states/button"
require "states/design"

-- Function to load UI elements for the save files screen
function gameSaves:load()
    -- Create text box and search button
    local buttons = {}
    local textBoxW = GameConfig.windowW / 2
    local textBoxH = GameConfig.windowH / 16

    local textBox = button:new("", temp, textBoxW, textBoxH)
    local searchButton = button:new("Search", search, textBoxW / 3, textBoxH)

    table.insert(buttons, textBox)
    table.insert(buttons, searchButton)

    -- Calculate position on screen
    textBox.yPos = textBox.yPos - textBox.height * 5
    searchButton.yPos = textBox.yPos
    searchButton.xPos = textBox.xPos + textBox.width + margin
    return buttons
end

-- Function to render the save files screen
function gameSaves:draw(buttons)
    love.graphics.setBackgroundColor(menuBackgroundColor)

    -- Draw UI elements
    local textBox, searchButton = buttons[1], buttons[2]
    textBox:draw(textBoxColor, smallFont, menuTextColor)
    searchButton:draw(searchButton.color, smallFont, menuTextColor)

    -- Display message prompt
    local prompt = "Enter your account username:"
    love.graphics.setColor(gameTitleColor)
    love.graphics.print(prompt, smallFont, textBox.xPos, textBox.yPos - (textBox.height + margin))
end

-- Placeholder function for search functionality
function search()
    print(string.format("Searching for %s's save file", "test"))
end

return gameSaves
