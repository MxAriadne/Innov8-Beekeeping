-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master/lume")
--local gd = require("game_data")

local SaveManager = {}

-- saving now
function SaveManager.save()
    -- update data
    GameData.Update_gameDataWGlobals()

    -- serialize and store
    local serialized = lume.serialize(GameData.gameData)
    love.filesystem.write("save2.lua", serialized)
    print("Game saved!")
    print("File saved to: " .. love.filesystem.getSaveDirectory())

end


--og name .load()
function SaveManager.loadGame()
    if love.filesystem.getInfo("save.lua") then
        -- get data from the file
        local data = love.filesystem.read("save.lua")
        local table = lume.deserialize(data)
        print("deserialized table is returned")

        -- update the variables with the saved values
        GameData.Update_GlobalsWgameData(table)
        return table
    else
        print("No save file found.")
        return nil
    end
end

return SaveManager
