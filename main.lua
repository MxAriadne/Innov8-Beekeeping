<<<<<<< Updated upstream
-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

local MenuState = require("states/MenuState")
local MainState = require("states/MainState")
=======
-- main.lua
-- 在原先的基础上，做了最小修改，增加：
-- 1) 金钱系统 (playerMoney)
-- 2) F/G/H 键购买建造模式, 右键点击放置
-- 3) 实时把 hive.honey 转化为金钱
-- 4) 显示金钱, 并在屏幕上同时绘制多对象
-- 5) 保留单一全局 hive/bee/flower 指向“最新放置”的对象，兼容老AI脚本

local DayCycle = require("dayCycleScript")
local Beehive  = require("libraries/beehive")
local Jumper   = require("libraries/jumper")
local MenuState= require("states/MenuState")
local MainState= require("states/MainState")
GameStateManager = require("libraries/gamestateManager")

-------------------------------------------------------
-- Global variables
-------------------------------------------------------
tintEnabled = false
debugMode   = false
GameConfig  = {}
>>>>>>> Stashed changes

-------------------------------------------------------
-- Money system + cost config
-------------------------------------------------------
playerMoney = 50
hiveCost    = 20
beeCost     = 5
flowerCost  = 3

-------------------------------------------------------
-- Arrays to store multiple objects
-------------------------------------------------------
hives   = {}
bees    = {}
flowers = {}

-- Current build mode: "hive", "bee", "flower", or nil
currentBuildMode = nil

function love.load()
<<<<<<< Updated upstream
    love.window.setMode(960, 640)
=======
    Object = require("classic")
    require("bee")
    require("flower")
    require("hive")
    require("wasp")
    require("honeybadger")

    -- 初始化一个默认 flower(供老AI脚本的 global 'flower' 引用)
    flower = Flower()
    table.insert(flowers, flower)

    music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    music:setLooping(true)
    music:play()
>>>>>>> Stashed changes

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

<<<<<<< Updated upstream
    GameStateManager:setState(MenuState)
=======
    -- Switch to main game state
    --GameStateManager:setState(MenuState)
    GameStateManager:setState(MainState)
>>>>>>> Stashed changes
end

function love.update(dt)
    -- 1) 更新当前 GameState
    GameStateManager:update(dt)
<<<<<<< Updated upstream
=======

    -- 2) 实时把所有 hives 的 honey 转化为金钱
    for _, h in ipairs(hives) do
        if h.honey > 0 then
            playerMoney = playerMoney + h.honey
            h.honey     = 0
        end
    end

    -- 3) 可选：更新多 hive, bee, flower
    for _, h in ipairs(hives) do
        h:update(dt)
    end
    for _, b in ipairs(bees) do
        b:update(dt)
    end
    for _, f in ipairs(flowers) do
        if f.update then
            f:update(dt)
        end
    end
>>>>>>> Stashed changes
end

function love.draw()
    GameStateManager:draw()
<<<<<<< Updated upstream
end
=======
    ApplyBGTint()

    -- 显示金钱 + buildMode
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Money: "..playerMoney, 10, 10)
    love.graphics.print("BuildMode: "..tostring(currentBuildMode or "none"), 10, 25)

    -- 绘制多个对象
    for _, h in ipairs(hives) do
        h:draw()
    end
    for _, b in ipairs(bees) do
        b:draw()
    end
    for _, f in ipairs(flowers) do
        f:draw()
    end
end

-------------------------------------------------------
-- 建造模式: 按 F/G/H 购买后 -> 右键放置
-------------------------------------------------------
function love.mousepressed(x, y, button)
    if button == 2 then  -- 右键
        if currentBuildMode == "hive" then
            local newHive = Hive()
            newHive.x = x
            newHive.y = y
            table.insert(hives, newHive)
            -- 让全局 hive 指向最新放置的 hive (兼容老AI)
            hive = newHive

            print("Placed a new hive at ("..x..","..y..")")
            currentBuildMode = nil

        elseif currentBuildMode == "bee" then
            local newBee = Bee()
            newBee.x = x
            newBee.y = y
            table.insert(bees, newBee)
            -- 让全局 bee 指向最新放置的 bee
            bee = newBee

            print("Placed a new bee at ("..x..","..y..")")
            currentBuildMode = nil

        elseif currentBuildMode == "flower" then
            local newFlower = Flower()
            newFlower.x = x
            newFlower.y = y
            table.insert(flowers, newFlower)
            -- 让全局 flower 指向最新放置的 flower
            flower = newFlower

            print("Placed a new flower at ("..x..","..y..")")
            currentBuildMode = nil

        else
            print("Right-clicked, but not in build mode.")
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        AdvanceDay()
        if tintEnabled then
            NightSky()
            tintEnabled = false
        else
            DaySky()
            tintEnabled = true
        end

    elseif key == "`" then
        debugMode = not debugMode

    -- F建造蜂巢
    elseif key == "f" then
        if playerMoney >= hiveCost then
            playerMoney     = playerMoney - hiveCost
            currentBuildMode= "hive"
            print("You purchased a hive blueprint. Right-click to place!")
        else
            print("Not enough money for a hive!")
        end

    -- G建造蜜蜂
    elseif key == "g" then
        if playerMoney >= beeCost then
            playerMoney     = playerMoney - beeCost
            currentBuildMode= "bee"
            print("You purchased a bee. Right-click to place!")
        else
            print("Not enough money for a bee!")
        end

    -- H建造花朵
    elseif key == "h" then
        if playerMoney >= flowerCost then
            playerMoney     = playerMoney - flowerCost
            currentBuildMode= "flower"
            print("You purchased a flower seed. Right-click to plant!")
        else
            print("Not enough money for a flower!")
        end
    end
end

-------------------------------------------------------
-- helper functions from Poultry Profits
-------------------------------------------------------
function checkCollision(a, b)
    return a.x < b.x + (b.width or b.size) and
           a.x + (a.width or a.size) > b.x and
           a.y < b.y + (b.height or b.size) and
           a.y + (a.height or a.size) > b.y
end

function isInPickupRange(a, b)
    local aCenterX = a.x + (a.width or a.size) / 2
    local aCenterY = a.y + (a.height or a.size) / 2
    local bCenterX = b.x + (b.width or b.size) / 2
    local bCenterY = b.y + (b.height or b.size) / 2
    local distance = math.sqrt((aCenterX - bCenterX)^2 + (aCenterY - bCenterY)^2)
    local range = 50
    return distance <= range
end

>>>>>>> Stashed changes
