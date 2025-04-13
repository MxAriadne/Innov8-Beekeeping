--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update and var refs

-- Total money the player has, starts out with 2000 KSh
PlayerMoney = 2000
-- Variable used to determine if day or night
TintEnabled = false
-- Variable used to determine if debug mode is on
DebugMode = false
-- This value is checked each state to determine if this is a new save or not
FirstRun = true
-- Timer for day/night cycle
Timer = 0
-- Interval for day/night cycle
Interval = 60
-- Last trigger time for day/night cycle
LastTrigger = 0
-- Locking mechanism to prevent skipping attacks
PressSpaceAllowed = true

-- Current build mode: "hive", "bee", "flower", or ""
CurrentBuildMode = ""


-- Make sure these variables are defined somewhere in your code before you use them
local days = 1  -- Example value
local hives = {}  -- Example empty table, replace with actual data
local flowers = {}  -- Example empty table, replace with actual data
local PlayerMoney = 100  -- Example value
local bees = {}  -- Example empty table, replace with actual data
local waspGo = false  -- Example value
local badgerGo = false  -- Example value
local PlayerName = ""

local gameData = {
    -- Total money the player has, starts out with 2000 KSh
PlayerMoney = PlayerMoney,
-- Variable used to determine if day or night
TintEnabled = TintEnabled,
-- Variable used to determine if debug mode is on
DebugMode = DebugMode,
-- This value is checked each state to determine if this is a new save or not
FirstRun = FirstRun,
-- Timer for day/night cycle
Timer = Timer,
-- Interval for day/night cycle
Interval = Interval,
-- Last trigger time for day/night cycle
LastTrigger = LastTrigger,
-- Locking mechanism to prevent skipping attacks
PressSpaceAllowed = PressSpaceAllowed,

-- Current build mode: "hive", "bee", "flower", or ""
CurrentBuildMode = CurrentBuildMode,


    -- hive health, level, count, positions
    --hives = hives,
    -- flower count, positions
    --flowers = flowers,
    -- honey count 
    -- honey = hive.honey,  -- maybe get honey from all hives
    -- money count
    --PlayerMoney = PlayerMoney,
    -- bee count
    --bees = bees,
    -- waspGo
    waspGo = waspGo,
    -- badgerGo
    badgerGo = badgerGo
    -- fence count, positions
    -- tool integrity n stuff
}

function Update_gameData()
    gameData.daysPassed = daysPassed
    gameData.waspGo = waspGo
    gameData.badgerGo = badgerGo
end

return gameData
