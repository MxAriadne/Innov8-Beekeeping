-- This file contains functions to implement the load save files
-- Author: Amelia Reiss

-- Import other files
local button = require "button"
require "design"

local gameSaves = {}

-- This function loads the elements for the page of save files
function gameSaves:load()
    -- Create text box and search button
    local buttons = {}
    local textBoxW = windowW / 2
    local textBoxH = windowH / 16

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

-- This function opens the page for accessing previous save files
function gameSaves:draw(buttons)
    -- Set background color
    love.graphics.setBackgroundColor(menuBackgroundColor)

    -- Draw text box and search button
    local textBox = buttons[1]
    local searchButton = buttons[2]
    textBox:draw(textBoxColor, smallFont, menuTextColor)
    searchButton:draw(searchButton.color, smallFont, menuTextColor)

    -- Write message prompt
    local text = "Enter your account username:"
    love.graphics.setColor(gameTitleColor)
    love.graphics.print(text, smallFont, textBox.xPos, textBox.yPos - (textBox.height + margin))

end

-- This placeholder function will call the username search function
-- defined elsewhere.
function search()
    print(string.format("Searching for %s's save file", "test"))
end

return gameSaves