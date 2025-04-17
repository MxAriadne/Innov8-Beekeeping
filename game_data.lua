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
    days = 0,
    Hives = {},     -- You can fill this with your hive info
    Flowers = {},
    Bees = {},
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
    days = 1,
    Hives = {},     -- You can fill this with your hive info
    Flowers = {},
    Bees = {},
    waspGo = false,
    badgerGo = false,
    PlayerName = ""

}

-- TODO: write this to update the table with current values
function gameData.update()
    gameData.PlayerMoney = PlayerMoney
    gameData.TintEnabled = TintEnabled
    gameData.DebugMode = DebugMode
    gameData.FirstRun = FirstRun
    gameData.Timer = Timer
    gameData.Interval = Interval
    gameData.LastTrigger = LastTrigger
    gameData.PressSpaceAllowed = PressSpaceAllowed
    gameData.CurrentBuildMode = CurrentBuildMode
    gameData.days = DaysPassed
    gameData.PlayerName = PlayerName
    gameData.waspGo = waspGo
    gameData.badgerGo = badgerGo

    gameData.Hives = lume.clone(Hives or {}, true)
    gameData.Flowers = lume.clone(Flowers or {}, true)
    gameData.Bees = lume.clone(Bees or {}, true)
end

function gameData.apply(data)
    for k, v in pairs(data) do
        gameData[k] = v
    end
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
    for key, value in pairs(data) do
        cleanedTable[key] = cleanForSave(value, visited)
    end

    return cleanedTable
end


-- This filters out any non-serializable values (like functions)
function gameData.getSerializableData()
    return {
        PlayerMoney = gameData.PlayerMoney,
        TintEnabled = gameData.TintEnabled,
        DebugMode = gameData.DebugMode,
        FirstRun = gameData.FirstRun,
        Timer = gameData.Timer,
        Interval = gameData.Interval,
        LastTrigger = gameData.LastTrigger,
        PressSpaceAllowed = gameData.PressSpaceAllowed,
        CurrentBuildMode = gameData.CurrentBuildMode,
        days = gameData.days,
        waspGo = gameData.waspGo,
        badgerGo = gameData.badgerGo,
        PlayerName = gameData.PlayerName,

        Hives = lume.map(Hives, cleanForSave),     -- deep copy to be safe
        Bees = lume.map(Bees, cleanForSave),
        Flowers = lume.map(Flowers, cleanForSave),
    }
end

return gameData
