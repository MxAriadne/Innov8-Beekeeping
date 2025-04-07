-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master/lume")
local gd = require("game_data")

local SaveManager = {}

function SaveManager.save()
    -- update data
    --gd.Update_gameData()

    -- serialize and store
    local serialized = lume.serialize(gd.gameData)
    love.filesystem.write("save.lua", serialized)
    print("Game saved!")
    print(gd)
    print(serialized)
    print("end")
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
