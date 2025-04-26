-- Import required modules
require "UI/design"
local button = require "UI/button"
local gameSaves = require "states.LoadFilesScreen"
local Settings = require "states/Settings"
local HUD = require "UI/HUD"

local PauseMenu = {}

-- This function displays the settings screen
function loadSettings()
    GameStateManager:setState(Settings)
    print (Settings)
end

-- This function generates and returns the buttons for the main menu
function PauseMenu:enter()
    self.buttons = {} -- Table of buttons for menu screen

    -- Variables for button placement and dimensions
    local buttonW = GameConfig.windowW / 3
    local buttonH = GameConfig.windowH / 10

    -- Create the buttons and add them to the table
    table.insert(self.buttons, button:new("Continue", continueGame, buttonW, buttonH))
    --table.insert(self.buttons, button:new("Load Game", loadGame, buttonW, buttonH))
    table.insert(self.buttons, button:new("Settings", loadSettings, buttonW, buttonH))
    table.insert(self.buttons, button:new("Exit", exitGame, buttonW, buttonH))

    -- Calculate each button's X and Y position
    for i, button in ipairs(self.buttons) do
        button.yPos = button.yPos - button.height + i * (button.height + margin)
    end

    -- Generate title and honeycomb
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
    love.graphics.setColor(GameTitleColor)
    self.honeycomb = love.graphics.newImage("sprites/honeycomb.png")

end

-- This function draws the created buttons on the screen
    function PauseMenu:draw()
        love.graphics.setColor(MenuBackgroundColor)
        love.graphics.rectangle("fill", 0, 0, GameConfig.windowW, GameConfig.windowH)
        
        -- Draw title
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(LargeFont) -- Make sure your font system is working
        love.graphics.printf("GAME PAUSED", 0, 100, GameConfig.windowW, "center")
        
        -- Draw the buttons
        for _, button in ipairs(self.buttons) do
            button:draw(colors.yellow, MediumFont, MenuTextColor)
        end
    end

function PauseMenu:mousepressed(x, y, b)
    print("Mouse pressed at " .. x .. ", " .. y)
    for _, button in ipairs(self.buttons) do
        button:mousepressed(x, y, b)
    end
end

-- This function exits the game
function exitGame()
    print("Exiting game")
    love.event.quit(0)
end

function continueGame()
    GameStateManager:revertState()
end

-- TODO: add function to change game state to gameSaves
function loadGame()
    GameStateManager:setState(gameSaves)
end

return PauseMenu
