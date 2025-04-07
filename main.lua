Object = require "libraries.classic"
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MainMenu = require("states/MainMenu")
local MainState = require("states/MainState")
local modal = require("UI/modal")

-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

GameConfig = {}

-------------------------------------------------------
 -- Money system + cost config
 -------------------------------------------------------
PlayerMoney = 100
HiveCost = 20
BeeCost = 5
QueenBeeCost = 25
FlowerCost = 3

 -------------------------------------------------------
 -- Arrays to store multiple objects
 -------------------------------------------------------
local hives = {}
local bees = {}
local flowers = {}

-- global variables
TintEnabled = false
DebugMode = false
FirstRun = true
Timer = 0
Interval = 30 -- how long user has each day/night before cycling
LastTrigger = 0
PressSpaceAllowed = true --locking mechanism so you cannot skip attacks


-- Current build mode: "hive", "bee", "flower", or nil
CurrentBuildMode = nil

function love.load()
    require "entities.bee"
    require "entities.flower"
    require "entities.hive"
    require "entities.wasp"
    require "entities.honeybadger"
    require "entities.player"
    require "entities.queenBee"

    --default flower, to be compatible with current implementation of enemy-behavior
    local flower = Flower()
    table.insert(flowers, flower)

    love.window.setMode(960, 640)

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    GameStateManager:setState(MainMenu)
end

function love.update(dt)
    GameStateManager:update(dt)

    --timer for daycycle (overridden by "space")
    Timer = Timer + dt
    if math.floor(Timer / Interval) > math.floor(LastTrigger / Interval) then
        print("Timer hit a multiple of Interval seconds: " .. math.floor(Timer))
        love.keypressed("space")
        LastTrigger = Timer
    end

    --converts honey to money
    for _, h in ipairs(hives) do
        if h.honey > 0 then
            PlayerMoney = PlayerMoney + h.honey
            h.honey = 0
        end
    end
end

function love.draw()
    GameStateManager:draw()
    modal:draw()
end


function love.mousepressed(x, y, b)
    local current = GameStateManager:getState()
    if current and current.mousepressed then
        current:mousepressed(x, y, b)
    end
    if modal:mousepressed(x, y, b) then return end
end

function love.keypressed(k)
    local current = GameStateManager:getState()
    if current and current.keypressed then
        current:keypressed(k)
    end
end