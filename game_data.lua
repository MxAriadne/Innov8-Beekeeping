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

    for _, entity in ipairs(Entities) do
        if entity.serialize then
            table.insert(GameData.gameData.entities, entity:serialize())
        end
    end

    if player and player.serialize then
        table.insert(GameData.gameData.entities, player:serialize())
    end

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

return GameData
