-- save manager for saving and loading

--TODO: fix how to create new world logic, then see if this helps clear up how entities are added

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
    GameData.Update_gameDataWGlobals()
    GameData.gameData.entities = Entity.getSaveData()

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

        --[[
            ***** LOADS ENTITIES *****
            If you want to test only loading basic variables,
            then set test = false.

            You will observe that the any entities you added from the shop do not appear,
            but the basic hive and bee and player will retain their functionality.

            If you add the entities (so far i am only testing hives, bees, and player),
            they will appear but not move/work.

            ***** serialize and deserialize calls *****
            The function calls are defined inside that entities lua file.
            So bee:deserialize() is defined in bee.lua.

            There is also the entity.getSaveData that adds all the entities to the 
            table to be saved, called in save() through gameData.update_gamDataWithGlobals
        ]]
        local loadentities = true;
        if loadentities then
            --clear existing entities to reload
            Entities = {}

            --count var to ensure loaded all entities in table
            local count = 0

            --rebuild entities
            if loadtable.entities then
                print("entities from table is valid")

                for _, entityData in ipairs(loadtable.entities) do
                    count = count + 1

                    print("entityData.type: " .. entityData.type)
                    if entityData.type == "hive" then
                        local hive = Hive.deserialize(entityData)
                        table.insert(Entities, hive)
                    elseif entityData.type == "bee" then
                        local bee = Bee.deserialize(entityData)
                        table.insert(Entities, bee)
                    elseif entityData.type == "player" then
                        local player = player.deserialize(entityData)
                        table.insert(Entities, player)
                    end --[[elseif entityData.type == "Flower" then
                    local flower = Flower.deserialize(entityData)
                    table.insert(Entities, flower)
                end]]
                end
                print("count: " .. count)
                -- Bee:init_Pathfinding() -- attempted to intitialize Pathfinding outside sine Pathfinding is a global - did not work
            end

            print("Entities table size after load: " .. #Entities)

        end -- loadentities condition end

        return loadtable
    else
        print("No save file found.")
        return nil
    end
end

return SaveManager
