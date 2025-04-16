-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master.lume")
local gameData = require("game_data")

local SaveManager = {}
textInput = textInput or "savegame"
local save_filename = ""--"savegame.lua" -- change to use username in filename to load

function SaveManager.save()


    --print("Hives:", lume.serialize(Hives))  -- You can use lume.serialize to log tables
    --print("Flowers:", lume.serialize(Flowers))
    --print("Bees:", lume.serialize(Bees))
    save_filename = textInput .. ".lua"

    -- update data
    gameData.update()

    local dataToSave = gameData.getSerializableData()
    -- serialize and store
    local serialized = lume.serialize(dataToSave)
    print("saving to : ".. save_filename)
    love.filesystem.write(save_filename, serialized)


    print("Game saved!")
    --print(dataToSave.PlayerMoney)
    --print(serialized)
    print("end")
end

function SaveManager.load(filename)
    
    print("loading filename: " .. filename)

    if love.filesystem.getInfo(filename) then
        local contents = love.filesystem.read(filename)
        local chunk = loadstring("return " .. contents)
        if chunk then
            local ok, data = pcall(chunk)
            if ok and type(data) == "table" then
                gameData.apply(data)
                print("Game loaded successfully.")
                return true
            else
                print("Load error: returned value is not a table")
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
