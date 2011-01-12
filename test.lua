-- 
--  test.lua
--  lua-astar
--  
--  Created by Jay Roberts on 2011-01-12.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
--  This is a simple test script which demonstrates the AStar class in use.
--


require 'astar'
require 'tiledmaphandler'


local handler = TiledMapHandler()
local astar = AStar(handler)


local start = {
  x = 2,
  y = 2
}

local goal = {
  x = 23,
  y = 23
}


local path = astar:findPath(start, goal)

if path ~= nil then
  print 'Path found'
else
  print 'No path'
end