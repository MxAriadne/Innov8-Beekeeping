-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

-- States holder file
local MainState = require("states/MainState")

function love.load()
    love.window.setMode(960, 640)

    GameStateManager:setState(MainState)
end

function love.update(dt)
    GameStateManager:update(dt)
end

function love.draw()
    GameStateManager:draw()
end
