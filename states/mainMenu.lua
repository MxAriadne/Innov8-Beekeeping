-- Main Menu Screen Implementation
-- Author: Amelia Reiss

-- Import required modules
local button = require "states/button"
local gameSaves = require "states/loadFilesScreen"
require "states/design"
local MainState = require("states/MainState")

local mainMenu = {}

-- This function generates and returns the buttons for the main menu
function mainMenu:load()
    local buttons = {} -- Table of buttons for menu screen

    -- Variables for button placement and dimensions
    local buttonW = GameConfig.windowW / 3
    local buttonH = GameConfig.windowH / 10

    -- Create the buttons and add them to the table
    table.insert(buttons, button:new("New Game", newGame, buttonW, buttonH))
    table.insert(buttons, button:new("Load Game", gameSaves.load, buttonW, buttonH))
    table.insert(buttons, button:new("Settings", loadSettings, buttonW, buttonH))
    table.insert(buttons, button:new("Exit", exitGame, buttonW, buttonH))

    -- Calculate each button's X and Y position
    for i, button in ipairs(buttons) do
        button.yPos = button.yPos - button.height + i * (button.height + margin)
    end

    return buttons
end

-- This function draws the created buttons on the screen
function mainMenu:draw(buttons)
    -- Set background color
    love.graphics.setBackgroundColor(menuBackgroundColor)

    -- Draw title centered to top of window
    local title = "Bizzy Beez"
    love.graphics.setColor(gameTitleColor)
    local titleW = largeFont:getWidth(title)
    love.graphics.print(title, largeFont, (GameConfig.windowW-titleW) / 2, margin)

    -- Draw the buttons
    for _, button in ipairs(buttons) do
        button:draw(button.color, mediumFont, menuTextColor)
    end
end

-- This function displays the settings screen
function loadSettings()
    -- TODO
    print ("Loading settings")
end

-- This function exits the game
function exitGame()
    print("Exiting game")
    love.event.quit(0)
end

function newGame()
    print("Current State Before:", GameStateManager:getState())
    GameStateManager:setState(MainState)
    print("Current State After:", GameStateManager:getState())
end


return mainMenu
