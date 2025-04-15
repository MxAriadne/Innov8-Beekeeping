local Pathfinding = {} --table to hold all functions in pathfinding.lua
local Grid = require("libraries/jumper.grid")
local Pathfinder = require("libraries/jumper.pathfinder")

--THIS CREATES A 42x30 GRID
local grid_width = 42
local grid_height = 30

--marking the whole grid as walkable for now (initializng all to 0)
--will probably handle obstructions in the future using conditionals to alter the grid
function Pathfinding:initialize()
    local grid_data = {}
    for y = 1, grid_height do
        grid_data[y] = {}
        for x = 1, grid_width do
            grid_data[y][x] = 0
        end
    end

    --creating Grid and Pathfinder
    self.grid = Grid(grid_data)
    self.pathfinder = Pathfinder(self.grid, 'JPS', 0)  --using Jump Point Search algorithm for its simplicity
end

--converts world coordinates to grid coordinates
function Pathfinding:worldToGrid(x, y)
    return math.floor(x / 23), math.floor(y / 22)
end

--convert grid coordinates to world coordinates
function Pathfinding:gridToWorld(grid_x, grid_y)
    return grid_x * 23, grid_y * 22
end

--finds a path from the wasp/hb's start position to the hive
function Pathfinding:findPathToHive(start_x, start_y, hive_x, hive_y)
    local start_grid_x, start_grid_y = self:worldToGrid(start_x, start_y)
    local hive_grid_x, hive_grid_y = self:worldToGrid(hive_x, hive_y)

    --calculating the path from the start point to the hive
    local path = self.pathfinder:getPath(
        start_grid_x, start_grid_y,
        hive_grid_x, hive_grid_y
    )

    --if a path is found, convert back to world coordinates and returning the list of coords
    if path then
        local world_path = {}
        for node, count in path:nodes() do
            local wx, wy = self:gridToWorld(node:getX(), node:getY())
            table.insert(world_path, {x = wx, y = wy})
        end
        return world_path
    end
    return nil
end

--finds a path from the bee's start position to a flower
function Pathfinding:findPathToFlower(start_x, start_y, flower_x, flower_y)
    --converting world to grid coordinates
    local start_grid_x, start_grid_y = self:worldToGrid(start_x, start_y)
    local flower_grid_x, flower_grid_y = self:worldToGrid(flower_x, flower_y)

    --getting a path to the flower
    local path = self.pathfinder:getPath(
        start_grid_x, start_grid_y,
        flower_grid_x, flower_grid_y
    )

    --if a path is found, convert to world coordinates and return the list of coords
    if path then
        local world_path = {}
        for node, count in path:nodes() do
            local wx, wy = self:gridToWorld(node:getX(), node:getY())
            table.insert(world_path, {x = wx, y = wy})
        end
        return world_path
    end
    return nil
end

--drawing the grid for debug
function Pathfinding:drawDebug()
    love.graphics.setColor(0.5, 0.5, 0.5, 0.25)
    for y = 0, grid_height do
        for x = 0, grid_width do
            local wx, wy = self:gridToWorld(x, y)
            love.graphics.rectangle("line", wx, wy, 23, 22)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Pathfinding:findPathToTarget(startX, startY, targetX, targetY)
    --converting world to grid coordinates
    local start_grid_x, start_grid_y = self:worldToGrid(startX, startY)
    local target_grid_x, target_grid_y = self:worldToGrid(targetX, targetY)

    --getting a path to the target
    local path = self.pathfinder:getPath(
        start_grid_x, start_grid_y,
        target_grid_x, target_grid_y
    )

    --if a path is found, convert to world coordinates and return the list of coords
    if path then
        local world_path = {}
        for node, count in path:nodes() do
            local wx, wy = self:gridToWorld(node:getX(), node:getY())
            table.insert(world_path, {x = wx, y = wy})
        end
        return world_path
    end
    return nil
end

return Pathfinding