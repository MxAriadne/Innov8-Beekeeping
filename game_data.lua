--holds game variables to be saved and loaded
-- Holds game variables to be saved and loaded

--TODO: fix update and var refs



-- Make sure these variables are defined somewhere in your code before you use them
--[[local days = 1  -- Example value
local hives = {}  -- Example empty table, replace with actual data
local flowers = {}  -- Example empty table, replace with actual data
local PlayerMoney = 100  -- Example value
local bees = {}  -- Example empty table, replace with actual data
local waspGo = false  -- Example value
local badgerGo = false  -- Example value
local PlayerName = ""]]

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
    --hives = {},     -- You can fill this with your hive info
    --flowers = {},
    --bees = {},
    waspGo = false,
    badgerGo = false,
    PlayerName = ""

}

-- TODO: write this to update the table with current values
function gameData.update()

end

function gameData.apply(data)
    for k, v in pairs(data) do
        gameData[k] = v
    end
end

return gameData
