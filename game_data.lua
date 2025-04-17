--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update entities, fix waspgo/badgergo save logic, fix new game loading, add new variables

-- import
local lume = require("libraries/lume-master.lume")

local default_gameData = {
    
    PlayerMoney = 2000,
    TintEnabled = false,
    DebugMode = false,
    FirstRun = true,
    Timer = 0,
    Interval = 60,
    LastTrigger = 0,
    PressSpaceAllowed = true,
    CurrentBuildMode = "",
    DaysPassed = 0,
    --Hives = {},     -- You can fill this with your hive info
    --Flowers = {},
    --Bees = {},
    waspGo = false,
    badgerGo = false,
    PlayerName = ""

}

local gameData = {
    
    PlayerMoney = 2000,
    TintEnabled = false,
    DebugMode = false,
    FirstRun = true,
    Timer = 0,
    Interval = 60,
    LastTrigger = 0,
    PressSpaceAllowed = true,
    CurrentBuildMode = "",
    DaysPassed = 0,
    --Hives = {},     -- You can fill this with your hive info
    --Flowers = {},
    --Bees = {},
    waspGo = false,
    badgerGo = false,
    PlayerName = ""

}

-- TODO: write this to update the table with current values
function gameData.updateSave()

    gameData.PlayerMoney = PlayerMoney
    gameData.TintEnabled = TintEnabled
    gameData.DebugMode = DebugMode
    gameData.FirstRun = FirstRun
    gameData.Timer = Timer
    gameData.Interval = Interval
    gameData.LastTrigger = LastTrigger
    gameData.PressSpaceAllowed = PressSpaceAllowed
    gameData.CurrentBuildMode = CurrentBuildMode
    gameData.DaysPassed = DaysPassed
    gameData.PlayerName = PlayerName
    gameData.waspGo = waspGo
    gameData.badgerGo = badgerGo

    

    --gameData.Hives = lume.clone(Hives or {}, true)
    --gameData.Flowers = lume.clone(Flowers or {}, true)
    ---gameData.Bees = lume.clone(Bees or {}, true)
    
end

--TODO: figure out why this is not actually applying the data from the file
function gameData.apply(data)
    print(Loaded)
    print("before apply: " .. gameData.DaysPassed)
    print(data)
    for k, v in pairs(data) do
        gameData[k] = v
    end
    print("after apply: " .. gameData.DaysPassed)
end

local function cleanForSave(data, visited)
    local dataType = type(data)

    if data == nil then
        return nil
    end

    -- Skip unsupported types
    if dataType == "function" or dataType == "userdata" or dataType == "thread" then
        return nil
    end

    -- Handle primitive types
    if dataType ~= "table" then
        return data
    end



    -- Initialize visited cache if it's the first call
    visited = visited or {}

    -- Avoid infinite loops from circular references
    if visited[data] then
        return nil
    end
    visited[data] = true

    -- Recursively clean table contents
    
    local cleanedTable = {}
    --[[for key, value in pairs(data) do
        cleanedTable[key] = cleanForSave(value, visited)
    end]]
    for key, value in pairs(data) do
        -- Skip known Windfield keys
        if key == "collider" or key == "body" or key == "fixture" or key == "shape" then
            -- skip it
        else
            local vType = type(value)
            if vType ~= "function" and vType ~= "userdata" and vType ~= "thread" then
                cleanedTable[key] = cleanForSave(value, visited)
            end
        end
    end

    return cleanedTable
end

--new
--[[
function gameData.resetToDefaults()
    for k, v in pairs(default_gameData) do
        if type(v) == "table" then
            gameData[k] = lume.clone(v, true)
        else
            gameData[k] = v
        end
    end
end
]]


-- This filters out any non-serializable values (like functions)
function gameData.getSerializableData()
    print("before getSerial: " .. DaysPassed)
   -- return {
        
        PlayerMoney = gameData.PlayerMoney
        TintEnabled = gameData.TintEnable
        DebugMode = gameData.DebugMode
        FirstRun = FirstRun
        Timer = gameData.Timer
        Interval = gameData.Interval
        LastTrigger = gameData.LastTrigger
        PressSpaceAllowed = gameData.PressSpaceAllowed
        CurrentBuildMode = gameData.CurrentBuildMode
        DaysPassed = gameData.DaysPassed
        waspGo = gameData.waspGo
        badgerGo = gameData.badgerGo
        PlayerName = gameData.PlayerName

        print("after getSerial: " .. DaysPassed)

        --Hives = lume.map(Hives, cleanForSave),     -- deep copy to be safe
        --Bees = lume.map(Bees, cleanForSave),
        --Flowers = lume.map(Flowers, cleanForSave),
   -- }

end

function gameData.updateWithDefault()
    print("before updateLoad: " .. DaysPassed)

    PlayerMoney = default_gameData.PlayerMoney
    TintEnabled = default_gameData.TintEnabled
    DebugMode = default_gameData.DebugMode
    FirstRun = default_gameData.FirstRun
    Timer = default_gameData.Timer
    Interval = default_gameData.Interval
    LastTrigger = default_gameData.LastTrigger
    PressSpaceAllowed = default_gameData.PressSpaceAllowed
    CurrentBuildMode = default_gameData.CurrentBuildMode
    DaysPassed = default_gameData.DaysPassed
    PlayerName = default_gameData.PlayerName
    waspGo = default_gameData.waspGo
    badgerGo = default_gameData.badgerGo

    print("adter updateLoad: " .. DaysPassed)

    --Hives = default_gameData.Hives
    --Flowers = default_gameData.Flowers
    --Bees = default_gameData.Bees
    
end

return gameData
