--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update and var refs

-- Make sure these variables are defined somewhere in your code before you use them

local gameData = {
    -- day number
    daysPassed = 0,
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
    --waspGo = waspGo,
    -- badgerGo
    --badgerGo = badgerGo
    -- fence count, positions
    -- tool integrity n stuff
}

function Update_gameDataWGlobals()
    gameData.daysPassed = daysPassed

end

function Update_GlobalsWgameData()
    daysPassed = gameData.daysPassed

end

return gameData
