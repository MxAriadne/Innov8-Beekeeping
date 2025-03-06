local MenuState = {}

local mainMenu = require "states/mainMenu"
local gameSaves = require "states/loadFilesScreen"

function MenuState:enter()
    mainMenu:enter()
end

function MenuState:update(dt)
end

function MenuState:draw()
    mainMenu:draw()
end

return MenuState
