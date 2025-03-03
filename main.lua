local Beehive = require("beehive")
local Jumper = require("jumper")

function love.load(arg)
    Object = require "classic"
    require "bee"
    require "flower"
    require "hive"

    hive = Hive()
    bee = Bee()
    flower = Flower()

    print("Beehive loaded successfully!") -- test
    
    -- another test
    if Jumper then
        print("Jumper loaded successfully!")
    else
        print("Failed to load Jumper.")
    end

    x = 100
    y = 50
-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

-- States holder file
local MainState = require("states/MainState")

function love.load()
    love.window.setMode(960, 640)

    GameStateManager:setState(MainState)
end
--[[
function love.update(dt)
    GameStateManager:update(dt)
end
--]]

function love.draw()
    love.graphics.setBackgroundColor(255, 105, 180)
    
    bee:draw()
    hive:draw()
    flower:draw()
    GameStateManager:draw()
end

