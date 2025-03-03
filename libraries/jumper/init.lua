local Jumper = {}

-- Require core modules
Jumper.Grid = require("libraries/jumper.grid")
Jumper.Pathfinder = require("libraries/jumper.pathfinder")

-- Require additional core files
Jumper.BHeap = require("libraries/jumper.core.bheap")
Jumper.Heuristics = require("libraries/jumper.core.heuristics")
Jumper.LookupTable = require("libraries/jumper.core.lookuptable")
Jumper.Node = require("libraries/jumper.core.node")
Jumper.Path = require("libraries/jumper.core.path")
Jumper.Utils = require("libraries/jumper.core.utils")

-- Require search algorithms
Jumper.AStar = require("libraries/jumper.search.astar")
Jumper.BFS = require("libraries/jumper.search.bfs")
Jumper.DFS = require("libraries/jumper.search.dfs")
Jumper.Dijkstra = require("libraries/jumper.search.dijkstra")
Jumper.JPS = require("libraries/jumper.search.jps")
Jumper.ThetaStar = require("libraries/jumper.search.thetastar")

return Jumper
