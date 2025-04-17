-- save manager for saving and loading

--TODO: fix update call and serialize/save. Load

local lume = require("libraries/lume-master.lume")
local gameData = require("game_data")

local SaveManager = {}
textInput = textInput or "savegame"
local save_filename = "" --"savegame.lua" -- change to use username in filename to load

function SaveManager.save()
    --print("Hives:", lume.serialize(Hives))  -- You can use lume.serialize to log tables
    --print("Flowers:", lume.serialize(Flowers))
    --print("Bees:", lume.serialize(Bees))
    save_filename = textInput .. ".lua"
    print("inside save: ".. PlayerMoney)
    -- update data
    gameData.updateSave()

    local dataToSave = gameData.getSerializableData()
    -- serialize and store
    local serialized = lume.serialize(dataToSave)
    print("saving to : " .. save_filename)
    love.filesystem.write(save_filename, serialized)
    print("Save location: " .. love.filesystem.getSaveDirectory())


    print("Game saved!")
    --print(dataToSave.PlayerMoney)
    --print(serialized)
    print("end")
end



function SaveManager.load(filename)
    if Loaded then
        print("loading filename: " .. filename)

        if love.filesystem.getInfo(filename) then
            local contents = love.filesystem.read(filename)
            local chunk = loadstring("return " .. contents)
            if chunk then
                local ok, data = pcall(chunk)
                print(data)
                if ok and type(data) == "table" then
                    gameData.apply(data)
                    --gameData.updateLoad()
                    gameData.getSerializableData()
                    print("Game loaded successfully.")
                    -- load logic for enemies
                    --Loaded = true
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
    else
        
        --gameData.resetToDefaults()  -- resets the gameData table itself

        -- load defualt table
        --print(default_gameData)
        --gameData.apply(default_gameData)
        gameData.updateWithDefault()
        print("loaded default game variables")
        --print(default_gameData.PlayerMoney)
        print(PlayerMoney)
    end
end

return SaveManager
