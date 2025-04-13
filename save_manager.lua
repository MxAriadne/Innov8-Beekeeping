-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master.lume")
local gameData = require("game_data")

local SaveManager = {}
local save_filename = "savegame.lua" -- change to use username in filename to load

function SaveManager.save()
    -- update data
    --gd.Update_gameData()

    -- serialize and store
    local serialized = lume.serialize(gameData.gameData)
    love.filesystem.write(save_filename, serialized)
    print("Game saved!")
    print(gameData.PlayerMoney)
    print(serialized)
    print("end")
end

function SaveManager.load(filename)
    if love.filesystem.getInfo(filename) then
        local contents = love.filesystem.read(filename)
        local chunk = loadstring("return " .. contents)
        if chunk then
            local data = chunk()
            if type(data) == "table" then
                gameData.apply(data)
                print("Game loaded successfully.")
                return true
            else
                print("Load error: returned value not a table")
            end
        else
            print("Load error: could not parse save file")
        end
    else
        print("No save file found.")
    end
    return false
end

return SaveManager
