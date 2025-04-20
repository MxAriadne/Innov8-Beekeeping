--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix entity logic if this is root of issue (i dont think it is)

-- Make sure these variables are defined somewhere in your code before you use them

local GameData = {}

GameData.gameData = {
    -- globally defined variables in main
    DaysPassed = 0,
    PlayerName = "Player",
    PlayerMoney = 3000,
    TintEnabled = false,
    DebugMode = false,
    FirstRun = true,
    Timer = 0,
    LastTrigger = 0,
    PressSpaceAllowed = true,

    -- add entities
    entities = {}


}


function GameData.Update_gameDataWGlobals()
    GameData.gameData.DaysPassed = DaysPassed
    GameData.gameData.PlayerName = PlayerName
    GameData.gameData.PlayerMoney = PlayerMoney
    GameData.gameData.TintEnabled = TintEnabled
    GameData.gameData.DebugMode = DebugMode
    GameData.gameData.FirstRun = FirstRun
    GameData.gameData.Timer = Timer
    GameData.gameData.LastTrigger = LastTrigger
    GameData.gameData.PressSpaceAllowed = PressSpaceAllowed

    -- entities

    -- Adds serialized entities to table (CANNOT ADD FUNCTIONS or USERDATA
    --(these things SHOULD be reintialized when entity:new() is
    -- called for each type for each entity in their own deserialize function)).
    GameData.gameData.entities = {}

    -- old serialize logic depends on serialize frunction for each type
    --[[for _, entity in ipairs(Entities) do
        if entity.serialize then
            table.insert(GameData.gameData.entities, entity:serialize())
        end
    end

    if player and player.serialize then
        table.insert(GameData.gameData.entities, player:serialize())
    end]]

    --[[print("---- Entities Dump ----")
for k, v in pairs(Entities) do
    print("Key:", k, "Type:", type(v))

    if type(v) == "table" then
        for field, value in pairs(v) do
            if type(value) ~= "function" then
                print("  ", field, "=", value)
            end
        end
    end
end]]

    -- new standard function
    GameData.gameData.entities = GameData.SaveEntities(GameData.gameData.entities)
end

-- Update glabals with the tables values. At the moment it works by using the newgame created and updates those variables.
function GameData.Update_GlobalsWgameData(data)
    DaysPassed = data.DaysPassed
    PlayerName = data.PlayerName
    PlayerMoney = data.PlayerMoney
    TintEnabled = data.TintEnabled
    DebugMode = data.DebugMode
    FirstRun = data.FirstRun
    Timer = data.Timer
    LastTrigger = data.LastTrigger
    PressSpaceAllowed = data.PressSpaceAllowed

    -- entities are loaded separately (In save_manager.loadGame())
end

-- handles tables inside entity data
function GameData.shallowCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        --[[if type(v) ~= "function" and type(v) ~= "userdata" then
            copy[k] = v
        end]]
        if v == "number" or v == "string" or v == "boolean" then
            copy[k] = v
        end
    end
    return copy
end

-- universal serialize each entitiy function
function GameData.serializeEntity(entity)
    local data = {}

    for k, v in pairs(entity) do
        local vType = type(v)

        -- skip function, userdata, threads, etc
        if vType == "number" or vType == "string" or vType == "boolean" then
            data[k] = v
        elseif vType == "table" then
            -- handle nested tables
            data[k] = GameData.shallowCopyTable(v)
        end
    end

    -- include entity type for recreating
    data.__entityType = entity.__entityType or entity.type or "unknown"

    return data
end

-- universal serialize function for entities
function GameData.SaveEntities(entitiesTable)
    -- loop through and skip any functions or nil values
    for key, v in pairs(Entities) do
        if type(v) == "table" then
            local serialized = GameData.serializeEntity(v)
            table.insert(entitiesTable, serialized)
            --GameData.eititiesTable[key] = GameData.serializeEntity(v) -- if they were key styles (they are list so dont use this)
        end
    end

    return entitiesTable
end

-- generic loading
-- regsitry to map names to classes
GameData.EntityRegistry = {
    bee = Bee,
    flower = Flower,
    bee_eater = BeeEater,
    Chest = Chest,
    --dewdrop = GoldenDewdrops,
    fence = Fence,
    hive = Hive,
    honey_badger = HoneyBadger,
    --langstrothhive = LangstrothHive,
    --lantana = CommonLantana,
    moth = Moth,
    player = Player,
    queenBee = QueenBee,
    --topbarhive = TopBarHive,
    wasp = Wasp,

}

--updates registry to current instances
function GameData.updateRegistry()
    GameData.EntityRegistry = {
        bee = Bee,
        flower = Flower,
        bee_eater = BeeEater,
        Chest = Chest,
        --dewdrop = GoldenDewdrops,
        fence = Fence,
        hive = Hive,
        honey_badger = HoneyBadger,
        --langstrothhive = LangstrothHive,
        --lantana = CommonLantana,
        moth = Moth,
        player = Player,
        queenBee = QueenBee,
        --topbarhive = TopBarHive,
        wasp = Wasp,
    
    }
end

-- deserializes data (individuals)
function GameData.deserializeEntity(data)

    local entityType = data.type      --data.__entityType
    print("deserializing datatype: "..entityType)

    local entityClass = GameData.EntityRegistry[entityType]

    if not entityClass then
        error("Unknown entity type: " .. tostring(entityType))
    end

    local entity = entityClass:new(data.x, data.y)
    -- Make sure entity.type exists before printing
    print("Created new entity of type: " .. tostring(entity.type or "nil"))

    -- Restore fields (skip anything like collider that’s created during :new())
    for k, v in pairs(data) do
        if k ~= "x" and k ~= "y" and k ~= "__entityType" and k ~= "state" then
            entity[k] = v
        elseif k == "state" and entityType == "bee" then
            entity[k] = "foraging" -- overide bee
        end
    end

    return entity
end

-- deserializes all entities
function GameData.LoadEntities(file)
    Entities = {}
    GameData.gameData.entities = file.entities

    for _, data in ipairs(GameData.gameData.entities or {}) do
        print("loadtable.entities entity type: " .. data.type)
        local entity = GameData.deserializeEntity(data)
        table.insert(Entities, entity)
    end
    -- if they were key styles (they are list so dont use this)
    --[[for key, data in pairs(GameData.savedEntities or {}) do
        Entities[key] = GameData.deserializeEntity(data)
    end]]
end

return GameData
