-- Config table, contains window related variables
GameConfig = { windowW = 960, windowH = 640, filter = "nearest" }

-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

-- Object library
Object = require "libraries.classic"

-- Globally declare the modal helper class so we can use it in any state.
modal = require("UI/modal")

-- Declare all states in main.
-- THIS MUST BE DONE IN MAIN OR IT WILL CAUSE RECIPROICAL IMPORT ERROR.
ShopScreen = require "states/ShopScreen"
MainMenu = require "states/MainMenu"
MainState = require "states/MainState"
Settings = require "states/Settings"
CharacterSelector = require "UI/CharacterSelector"

SaveManager = require "save_manager"
GameData = require "game_data"

-- All variables that need to be saved should be global variables for sake of my sanity.
DaysPassed = 0.0
-- Set player name, used for save files.
PlayerName = "Player"
-- Total money the player has, starts out with 2000 KSh
PlayerMoney = 3000
-- Variable used to determine if day or night
TintEnabled = false
-- Variable used to determine if debug mode is on
DebugMode = false
-- This value is checked each state to determine if this is a new save or not
FirstRun = true
-- Timer for day/night cycle
Timer = 0
-- Interval for day/night cycle
Interval = 60
-- Last trigger time for day/night cycle
LastTrigger = 0
-- Locking mechanism to prevent skipping attacks
PressSpaceAllowed = true

-- Current build mode: "hive", "bee", "flower", or ""
CurrentBuildMode = ""

-- to get username
textInput = ""

-- Direction constants
DIRECTIONS = {
    [0] = "left",
    [1] = "right",
    [2] = "up",
    [3] = "down",
    [4] = "still"
}

function love.load()
    -- Load entities
    require "entities.entity"
    require "entities.bee"
    require "entities.flower"
    require "entities.hive"
    require "entities.wasp"
    require "entities.bee_eater"
    require "entities.moth"
    require "entities.honey_badger"
    require "entities.player"
    require "entities.queenBee"
    require "entities.langstrothhive"
    require "entities.topbarhive"
    require "entities.lantana"
    require "entities.dewdrop"
    require "entities.fence"
    require "entities.chest"

    -- Set default filter for graphics
    love.graphics.setDefaultFilter(GameConfig.filter, GameConfig.filter)
    love.window.setMode(GameConfig.windowW, GameConfig.windowH)

    -- Set initial state
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
    -- Forward draw to current state
    GameStateManager:draw()
    -- Draw modal
    modal:draw()
end

function love.mousepressed(x, y, b)
    -- Forward mouse input to current state
    local current = GameStateManager:getState()
    if current and current.mousepressed then
        current:mousepressed(x, y, b)
    end
    if modal:mousepressed(x, y, b) then return end
end

function love.textinput(text)
    -- Block text input when modal is up
    if modal.active then return end
    -- Forward text input to current state
    if GameStateManager.currentState and GameStateManager.currentState.textinput then
        GameStateManager.currentState:textinput(text)
    end
end

function love.keypressed(k)
    -- Block key input when modal is up
    if modal.active then return end
    -- Forward key input to current state
    local current = GameStateManager:getState()
    if current and current.keypressed then
        current:keypressed(k)
    end
end