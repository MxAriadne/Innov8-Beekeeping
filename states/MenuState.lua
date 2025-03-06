local MenuState = {}

local mainMenu = require "states/mainMenu"
local gameSaves = require "states/loadFilesScreen"

function MenuState:enter()
    self.buttons = mainMenu:load()
end

function MenuState:update(dt)
end

function MenuState:draw()
    if self.buttons then  -- Ensure buttons exist before drawing
        mainMenu:draw(self.buttons)
    else
        print("Error: Buttons table is nil in MenuState:draw()")
    end
end

return MenuState