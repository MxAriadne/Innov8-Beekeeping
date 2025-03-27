Object = require "classic" -- ran into issues without this first

local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MenuState = require("states/MenuState")
local MainState = require("states/MainState")
GameStateManager = require("libraries/gamestateManager")

-- global variables
tintEnabled = false
debugMode = false

GameConfig = {}

-------------------------------------------------------
 -- Money system + cost config
 -------------------------------------------------------
playerMoney = 50
hiveCost = 20
beeCost = 5
flowerCost = 3


 -------------------------------------------------------
 -- Arrays to store multiple objects
 -------------------------------------------------------
hives = {}
bees = {}
flowers = {}

-- Current build mode: "hive", "bee", "flower", or nil
currentBuildMode = nil

function love.load()
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"
    require "player"
    
    --default flower, to be compatible with current implementation of enemy-behavior
    flower = Flower()
    table.insert(flowers, flower)

    music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    music:setLooping(true)  --music loop
    music:play()  --playing the music

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    --commenting out menu state for now while working on the main state
    --GameStateManager:setState(MenuState)
    GameStateManager:setState(MainState)
end


function love.update(dt)
    GameStateManager:update(dt)
    --dia:update(dt) -- update dia system
    
    --converts honey to money
    for _, h in ipairs(hives) do
        if h.honey > 0 then
            playerMoney = playerMoney + h.honey
            h.honey = 0
        end
    end
end

function love.draw()
    GameStateManager:draw()
    ApplyBGTint()
end

--build mode (right click)
function love.mousepressed(x, y, button)
    if button == 2 then
        if currentBuildMode == "hive" then
            local newHive = Hive()
            newHive.x = x
            newHive.y = y
            table.insert(hives, newHive)
            --makes global hive point to newest hive
            hive = newHive
            
            print("placed a new hive at (" .. x .. "," .. y .. ")")
            currentBuildMode = nil
            
        elseif currentBuildMode == "bee" then
            local newBee = Bee()
            newBee.x = x
            newBee.y = y
            table.insert(bees, newBee)
            --global bee points to new bee
            bee = newBee
            
            print("placed a new bee at (" .. x .. "," .. y .. ")")
            currentBuildMode = nil
            
        elseif currentBuildMode == "flower" then
            local newFlower = Flower()
            newFlower.x = x
            newFlower.y = y
            table.insert(flowers, newFlower)
            --makes global flower point to newest flower
            flower = newFlower
            
            print("placed a new flower at (" .. x .. "," .. y .. ")")
            currentBuildMode = nil
        end
    end
end

-- trigger event for day cycle
function love.keypressed(key)
    -- Check if the key for advancing the day was pressed
    if key == "space" then
        AdvanceDay()  -- Call the trigger updates function from dayCycleScript.lua
        if tintEnabled then
            NightSky()
            tintEnabled = false
        else
            DaySky()
            tintEnabled = true
        end

    --pathfinding debug toggle
    elseif key == "`" then  --tilde key
        debugMode = not debugMode
        
    --f key to build hive
    elseif key == "f" then
        if playerMoney >= hiveCost then
            playerMoney = playerMoney - hiveCost
            currentBuildMode = "hive"
            print("You purchased a hive blueprint. Right-click to place!")
        else
            print("Not enough money for a hive!")
        end
        
    --g key to build bee
    elseif key == "g" then
        if playerMoney >= beeCost then
            playerMoney = playerMoney - beeCost
            currentBuildMode = "bee"
            print("You purchased a bee. Right-click to place!")
        else
            print("Not enough money for a bee!")
        end
        
    --h key to build flower
    elseif key == "h" then
        if playerMoney >= flowerCost then
            playerMoney = playerMoney - flowerCost
            currentBuildMode = "flower"
            print("You purchased a flower seed. Right-click to plant!")
        else
            print("Not enough money for a flower!")
        end
    end
end
