--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update and var refs

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
    --bees (type(queen, worker), location, health)
    --hives(type(), location, health)
    --flowers(type(), location)

    -- inventory
    --brush (integrity)
    --mesh (integrity)
    --smoker (integrity)

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
end

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
end

return GameData
