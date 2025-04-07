Object = require "libraries.classic"
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")

-- Globally declare the modal helper class so we can use it in any state.
modal = require("UI/modal")

-- Declare all states in main.
-- THIS MUST BE DONE IN MAIN OR IT WILL CAUSE RECIPROICAL IMPORT ERROR.
shopScreen = require "states/shopScreen"
MainMenu = require "states/MainMenu"
MainState = require "states/MainState"
Settings = require "states/Settings"
CharacterSelector = require "UI/CharacterSelector"

-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

GameConfig = {}

-------------------------------------------------------
 -- Money system + cost config
 -------------------------------------------------------
PlayerMoney = 100

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

    love.window.setMode(960, 640)

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    GameStateManager:setState(MainMenu)
end

function love.update(dt)
    if not modal.active then
        GameStateManager:update(dt)

        --timer for daycycle (overridden by "space")
        Timer = Timer + dt
        if math.floor(Timer / Interval) > math.floor(LastTrigger / Interval) then
            --print("Timer hit a multiple of Interval seconds: " .. math.floor(Timer))
            love.keypressed("space")
            LastTrigger = Timer
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

function love.textinput(text)
    if modal.active then return end -- block text input when modal is up
    if GameStateManager.currentState and GameStateManager.currentState.textinput then
        GameStateManager.currentState:textinput(text)
    end
end

function love.keypressed(k)
    if modal.active then return end -- block text input when modal is up
    local current = GameStateManager:getState()
    if current and current.keypressed then
        current:keypressed(k)
    end
end