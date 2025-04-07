--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update and var refs

-- Make sure these variables are defined somewhere in your code before you use them
local days = 1  -- Example value
local hives = {}  -- Example empty table, replace with actual data
local flowers = {}  -- Example empty table, replace with actual data
local PlayerMoney = 100  -- Example value
local bees = {}  -- Example empty table, replace with actual data
local waspGo = false  -- Example value
local badgerGo = false  -- Example value

local gameData = {
    -- day number
    daysPassed = daysPassed,
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
