local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MainState = require("states/MainState")
GameStateManager = require("libraries/gamestateManager")

function love.load()
    Object = require "classic"
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"
    
    hive = Hive()
    bee = Bee()
    flower = Flower()
    honeybadger = HoneyBadger()
    wasp = Wasp()
    
    -- table for flowers
    flowers = {flower}

    GameStateManager:setState(MainState)

    dia = Dia()
    dia:loadDialogs("dialogs.lua") -- load dialogue script
end

function love.update(dt)
    GameStateManager:update(dt)
    dia:update(dt) -- update dia system
end

function love.draw()
    GameStateManager:draw()
end

-- helper functions from Poultry Profits
function checkCollision(a, b)
    return a.x < b.x + (b.width or b.size) and
           a.x + (a.width or a.size) > b.x and
           a.y < b.y + (b.height or b.size) and
           a.y + (a.height or a.size) > b.y
end

function isInPickupRange(a, b)
    local aCenterX = a.x + (a.width or a.size) / 2
    local aCenterY = a.y + (a.height or a.size) / 2
    local bCenterX = b.x + (b.width or b.size) / 2
    local bCenterY = b.y + (b.height or b.size) / 2
    local distance = math.sqrt((aCenterX - bCenterX)^2 + (aCenterY - bCenterY)^2)
    local range = 50  -- Adjusted pickup range
    return distance <= range
end

-- trigger event for day cycle
function love.keypressed(key)
    -- Check if the key for advancing the day was pressed
    if key == cycleKey then
        print("advancing day")
        AdvanceDay()  -- Call the day/night cycle function from dayCycleScript.lua
    end
end