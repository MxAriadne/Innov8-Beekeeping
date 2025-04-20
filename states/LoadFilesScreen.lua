-- Load Save Files Implementation
-- Author: Amelia Reiss

local gameSaves = {}

-- Import required modules
local button = require "UI/button"
local textbox = require "UI/textbox"
require "UI/design"

-- Save/Load imports
local SaveManager = require "save_manager"
local GameData = require "game_data"
local gameState = require("states/MainState")

local textBoxColor = colors.grey
local lastSearch = nil


-- Function to load UI elements for the save files screen
function gameSaves:enter()
    -- Create text box and search button
    local textBoxW = GameConfig.windowW / 2
    local textBoxH = GameConfig.windowH / 16
    self.textBox = textbox:new(textBoxW, textBoxH)
    self.searchButton = button:new("Search", 
                                function()
                                    gameSaves:search(self.textBox.text )
                                end, textBoxW / 3, textBoxH)

    -- Calculate position on screen
    self.textBox.yPos = self.textBox.yPos - self.textBox.height * 5
    self.searchButton.yPos = self.textBox.yPos
    self.searchButton.xPos = self.textBox.xPos + self.textBox.width + margin

    return self.buttons
end

function gameSaves:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end

    self.textBox:update(dt)
end

-- Function to render the save files screen
function gameSaves:draw()
    love.graphics.setBackgroundColor(MenuBackgroundColor)

    -- Draw UI elements
    self.textBox:draw(SmallFont)
    self.searchButton:draw(colors.yellow, SmallFont, MenuTextColor)

    -- Display message prompt
    local prompt = "Enter your account username:"
    love.graphics.setColor(GameTitleColor)
    love.graphics.print(prompt, SmallFont, self.textBox.xPos, self.textBox.yPos - (self.textBox.height + margin))

    -- Display message after search
    if lastSearch and lastSearch ~= "" then
        love.graphics.setColor(MenuTextColor)
        love.graphics.setFont(MediumFont)
        local message = string.format("Results for \"%s\":", lastSearch)
        love.graphics.print(message, self.textBox.xPos / 2, self.textBox.yPos + 70)
    end

    
end

function gameSaves:mousepressed(x, y, b)
    self.textBox:mousepressed(x, y, b)
    self.searchButton:mousepressed(x, y, b)
end

function gameSaves:textinput(t)
    self.textBox:textinput(t)
end

function gameSaves:keypressed(k)
    self.textBox:keypressed(k)
end

-- ****** search for save file ******
function gameSaves:search(name)
    lastSearch = name
    print(string.format("Searching for %s's save file", lastSearch))
        
    if name == nil or name == "" then
        print("No username entered.")
        return
    end

    local filename = name .. ".lua"

    if love.filesystem.getInfo(filename) then
        -- check if first new game, else it needs to destroy
        NewWorldCount = NewWorldCount + 1
        if NewWorldCount > 1 then
            DeleteOldWorld = true
        else
            DeleteOldWorld = false
        end

        FirstRun = false
        GameStateManager:setState(gameState)
        local loaded = SaveManager.loadGame(filename)--pass filename
        if loaded then
            print("Save file loaded. Switching to game.")
            --FirstRun = true  -- samtest
            --GameStateManager:setState(gameState) -- <- switch to your game state
        else
            print("Save file exists but failed to load.")
        end
    else
        print("No save file found for: " .. name)
    end
end

return gameSaves
