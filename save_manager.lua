-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master/lume")
local gd = require("game_data")

local SaveManager = {}

-- not saving now
function SaveManager.save()
    -- update data
    gd.Update_gameDataWGlobals()

    -- serialize and store
    local serialized = lume.serialize(gd.gameData)
    love.filesystem.write("save.lua", serialized)
    print("Game saved!")

end

--og name .load(), now only being called in this file.
function SaveManager.loadGame()
    if love.filesystem.getInfo("save.lua") then
        local chunk = love.filesystem.load("save.lua")
        return chunk()  -- returns the loaded table
    else
        print("No save file found.")
        return nil
    end
end

local loadedData = loadGame("save.lua")

if loadedData then
    print("Loaded Dayspassed: ", loadedData.daysPassed)
end

return SaveManager
