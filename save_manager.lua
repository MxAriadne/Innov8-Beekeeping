-- save manager for saving and loading

local lume = require("libraries/lume-master/lume")

local SaveManager = {}

function SaveManager.save(data)
    local serialized = lume.serialize(data)
    love.filesystem.write("save.lua", serialized)
    print("Game saved!")
end

function SaveManager.load()
    if love.filesystem.getInfo("save.lua") then
        local chunk = love.filesystem.load("save.lua")
        return chunk()  -- returns the loaded table
    else
        print("No save file found.")
        return nil
    end
end

return SaveManager
