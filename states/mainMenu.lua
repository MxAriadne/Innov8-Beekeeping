-- Main Menu Screen Implementation
-- Author: Amelia Reiss

-- Import required modules
require "UI/design"
local button = require "UI/button"
local gameSaves = require "states/loadFilesScreen"
local MainState = require("states/MainState")

local mainMenu = {}

-- This function generates and returns the buttons for the main menu
function mainMenu:enter()
    self.buttons = {} -- Table of buttons for menu screen

    -- Variables for button placement and dimensions
    local buttonW = GameConfig.windowW / 3
    local buttonH = GameConfig.windowH / 10

    -- Create the buttons and add them to the table
    table.insert(self.buttons, button:new("New Game", newGame, buttonW, buttonH))
    table.insert(self.buttons, button:new("Load Game", loadGame, buttonW, buttonH))
    table.insert(self.buttons, button:new("Settings", loadSettings, buttonW, buttonH))
    table.insert(self.buttons, button:new("Exit", exitGame, buttonW, buttonH))

    -- Calculate each button's X and Y position
    for i, button in ipairs(self.buttons) do
        button.yPos = button.yPos - button.height + i * (button.height + margin)
    end

    -- Generate logo
    self.logo = love.graphics.newImage("sprites/logo.png")
    self.logoCanvas = love.graphics.newCanvas(280, 280)
    love.graphics.setCanvas(self.logoCanvas) -- Switch drawing to canvas
    love.graphics.clear(0, 0, 0, 0) -- Make new canvas transparent
    love.graphics.setColor(1,1,1) -- Set color back to default
    love.graphics.draw(self.logo, 0, 0, 0,
                        self.logoCanvas:getWidth() / self.logo:getWidth(),
                        self.logoCanvas:getHeight() / self.logo:getHeight()) -- Draw image onto canvas
    love.graphics.setCanvas() -- Swtich back to screen

    -- self.title = "Bizzy Beez"
    -- love.graphics.setColor(gameTitleColor)
    -- self.titleW = largeFont:getWidth(self.title)
    -- self.honeycomb = love.graphics.newImage("sprites/honeycomb.png")

end

-- This function draws the created buttons on the screen
function mainMenu:draw()
    -- Set background color
    love.graphics.setBackgroundColor(menuBackgroundColor)

    -- Draw title centered to top of window
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.logoCanvas, (GameConfig.windowW - self.logoCanvas:getWidth()) / 2, 10)

    -- Draw honeycomb image
    -- love.graphics.setColor(1,1,1)
    -- love.graphics.draw(self.honeycomb, -80, GameConfig.windowH - 280)
    -- love.graphics.draw(self.honeycomb, GameConfig.windowW - 280, 85)

    -- Draw the buttons
    for _, button in ipairs(self.buttons) do
        button:draw(menuButtonColor, mediumFont, menuTextColor)
    end
end

function mainMenu:mousepressed(x, y, b)
    for _, button in ipairs(self.buttons) do
        button:mousepressed(x, y, b)
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

-- TODO: add function to change game state to gameSaves
function loadGame()
    print("Current State Before:", GameStateManager:getState())
    GameStateManager:setState(gameSaves)
    print("Current State After:", GameStateManager:getState())
end

return mainMenu
