-- save manager for saving and loading

--TODO: Fix wf so that it does not throw errors when laoding entities

local lume = require("libraries/lume-master/lume")

local SaveManager = {}

-- saves current values of variables and writes to file
function SaveManager.save()

    -- get username to write to
    local name = ""
    if textInput == "" then
        name = "default_save"
    else
        name = textInput
    end

    -- create filename
    local filename = name .. ".lua"

    -- update data to be saved
    GameData.Update_gameDataWGlobals() -- updates entities within this function

    -- serialize and store
    local serialized = lume.serialize(GameData.gameData)
    love.filesystem.write(filename, serialized)

    print("Game saved!")
    print("File saved to: " .. love.filesystem.getSaveDirectory()) -- use to view og save file
end

-- Loads game values from file
function SaveManager.loadGame(filename)
    -- tried to reload new game manually here to see if this would fix having
        -- to click new game before loading game.
        -- load new world first then apply changes
    -- ERROR: attempt to index feild 'wf' a nil value when calling newRectangleCollider
    --[[FirstRun = true;
    GameStateManager:setState(MainState)
    FirstRun = false;]]

    if love.filesystem.getInfo(filename) then
        --update registry
        GameData.updateRegistry()

        -- get data from the file
        local data = love.filesystem.read(filename)
        local loadtable = lume.deserialize(data)
        print("deserialized table is returned")

        -- update the variables with the saved values
        GameData.Update_GlobalsWgameData(loadtable) -- this loads updated simple variable values

        -- prints save table to ensure saving was not the issue
        print("---- Dumping raw deserialized entity data ----")
        if loadtable.entities then
            for k, v in pairs(loadtable.entities) do
                print(k, v.type, lume.serialize(v))
            end
        else
            print("No entities found in deserialized table")
        end
        print("---- Done ----")

        --[[***** LOADS ENTITIES *****]]
        GameData.LoadEntities(loadtable)

        -- debug print
        print("After loading entities")
        for i, entity in ipairs(Entities) do
            print("Entity " .. i .. ": type = " .. tostring(entity.type) .. ", collider = " .. tostring(entity.collider))
        end
        print("Level is Windfield world:", Level and Level.newRectangleCollider and "yes" or "no")


        return loadtable
    else
        print("No save file found.")
        return nil
    end
end

return SaveManager
