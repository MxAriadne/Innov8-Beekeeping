local Jumper = {}

-- Require core modules
Jumper.Grid = require("jumper.grid")
Jumper.Pathfinder = require("jumper.pathfinder")

-- Require additional core files
Jumper.BHeap = require("jumper.core.bheap")
Jumper.Heuristics = require("jumper.core.heuristics")
Jumper.LookupTable = require("jumper.core.lookuptable")
Jumper.Node = require("jumper.core.node")
Jumper.Path = require("jumper.core.path")
Jumper.Utils = require("jumper.core.utils")

-- Require search algorithms
Jumper.AStar = require("jumper.search.astar")
Jumper.BFS = require("jumper.search.bfs")
Jumper.DFS = require("jumper.search.dfs")
Jumper.Dijkstra = require("jumper.search.dijkstra")
Jumper.JPS = require("jumper.search.jps")
Jumper.ThetaStar = require("jumper.search.thetastar")

return Jumper