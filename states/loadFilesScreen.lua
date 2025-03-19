-- Load Save Files Implementation
-- Author: Amelia Reiss

local gameSaves = {}

-- Import required modules
local button = require "UI/button"
require "UI/design"

-- Design elements
local textBoxColor = colors.grey

-- Function to load UI elements for the save files screen
function gameSaves:enter()
    -- Create text box and search button
    self.buttons = {}
    local textBoxW = GameConfig.windowW / 2
    local textBoxH = GameConfig.windowH / 16

    local textBox = button:new("", temp, textBoxW, textBoxH)
    local searchButton = button:new("Search", search, textBoxW / 3, textBoxH)

    table.insert(self.buttons, textBox)
    table.insert(self.buttons, searchButton)

    -- Calculate position on screen
    textBox.yPos = textBox.yPos - textBox.height * 5
    searchButton.yPos = textBox.yPos
    searchButton.xPos = textBox.xPos + textBox.width + margin

    return self.buttons
end

function gameSaves:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end
end

-- Function to render the save files screen
function gameSaves:draw()
    love.graphics.setBackgroundColor(menuBackgroundColor)

    -- Draw UI elements
    local textBox, searchButton = self.buttons[1], self.buttons[2]
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
