local MainState = {}

--libraries import from libraries folder
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'

function MainState:enter()

    --base size for the game right now
    --will put everything into variables later so it can be more easily resized
    money = 0
    map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')
    love.window.setMode(960, 640)

    world = wf.newWorld()

    --player creation and collider configuation
    player = {}
    player.collider = world:newBSGRectangleCollider(480, 340, 20, 20, 14)
    player.collider:setFixedRotation(true)
    player.x = 480
    player.y = 320
    player.speed = 300

    --auto-getting and making the colliders from the objects created in Tiled
    walls = {}
    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x*2, obj.y*2, obj.width*2, obj.height*2)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    --creating the entities instance variables
    self.hive = Hive()
    self.bee = Bee()
    self.flower = Flower()
    self.honeybadger = HoneyBadger()
    self.wasp = Wasp()
    
    --assigning the instances to global variables for accessibility
    hive = self.hive
    bee = self.bee
    flower = self.flower
    honeybadger = self.honeybadger
    wasp = self.wasp

    --making the hive collider using values in hive.lua instead of hardcoding
    local wall = world:newRectangleCollider(self.hive.x, self.hive.y, self.hive.width, self.hive.height)
    wall:setType('static')
end

function MainState:update(dt)
    --player movement with colliders
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    local vx = 0
    local vy = 0
    if love.keyboard.isDown("right", 'd') then
        vx = player.speed
    end

    if love.keyboard.isDown("left", 'a') then
        vx = player.speed * -1
    end

    if love.keyboard.isDown("up", 'w') then
        vy = player.speed * -1
    end

    if love.keyboard.isDown("down", 's') then
        vy = player.speed
    end

    --updating the entities (making them move) IF they exist
    if self.wasp then self.wasp:update(dt) end
    if self.bee then self.bee:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end
    
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end

    player.collider:setLinearVelocity(vx, vy)

end

--still making this
function MainState:keypressed(key)
   if (key == "e") then
      money = money + 5
      print(money)
   end
end

function MainState:draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    map:draw(0, 0, 2, 2)
    
    --drawing the entities if they exist
    if self.bee then self.bee:draw() end
    if self.flower then self.flower:draw() end
    if self.wasp then self.wasp:draw() end
    if self.honeybadger then self.honeybadger:draw() end
    if self.hive then self.hive:draw() end

    --debug mode
    if debugMode and self.wasp then
        self.wasp.pathfinding:drawDebug()
    end


    world:draw()--makes the colliders visible, for debugging - comment out later
    love.graphics.circle("line", player.x, player.y, 20)
    --hiveTagColor = {.3, 0, 0, 1}
    --love.graphics.print({hiveTagColor, "Beehive: Level 1"}, 70, 195, 0, 1.5, 1.5)

end

return MainState
