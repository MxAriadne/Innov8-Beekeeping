--holds game variables to be saved and loaded

local gameData = {
    -- day number
    day = daysPassed,
    -- hive health, level, count, positions
    hives,
    -- flower count, positions
    flowers,
    -- honey count
    --honey = hive.honey, -- maybe get honey from all hives
    -- money count
    PlayerMoney,
    -- bee count
    bees,
    -- waspGo
    waspGo,
    -- badgerGo
    badgerGo
    -- fence count, positions
    -- tool integrity n stuff

}

return gameData
