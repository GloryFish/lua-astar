-- 
--  examplemaphandler.lua
--  lua-astar
--  
--  Created by Jay Roberts on 2011-01-10.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
--  Licensed under the MIT License
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--  
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--  
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.

--  This is an example of a class that is responsible for providing nodes to the AStar
--  class and determining if they are walkable, equivalent, and calculating their costs.
--
--  You could implement these methods in your Level class, for example, and then
--  pass your whole level to the AStar class to use as the handler.

require 'middleclass'

Handler = class('Handler')

function Handler:initialize()
end

function Handler:getNode(location)
  -- Here you make sure the requested node is valid (i.e. on the map, not blocked)
  -- if the location is not valid, return nil, otherwise return a new Node object
  return Node(location, 1, location.y * #self.tiles[1] + location.x)
end

function Handler:locationsAreEqual(a, b)
  -- Here you check to see if two locations (not nodes) are equivalent
  -- If you are using a vector for a location you may be able to simply
  -- return a == b
  -- however, if your location is represented some other way, you can handle 
  -- it correctly here without having to modufy the AStar class
  return a.x == b.x and a.y == b.y
end

function Handler:getAdjacentNodes(curnode, dest)
  -- Given a node, return a table containing all adjacent nodes
  -- The code here works for a 2d tile-based game but could be modified
  -- for other types of node graphs
  local result = {}
  local cl = curnode.location
  local dl = dest
  
  local n = false
  
  n = self:_handleNode(cl.x + 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x - 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y + 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y - 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end
  
  return result
end

function Handler:_handleNode(x, y, fromnode, destx, desty)
  -- Fetch a Node for the given location and set its parameters
  local n = self:getNode(vector(x, y))

  if n ~= nil then
    local dx = math.max(x, destx) - math.min(x, destx)
    local dy = math.max(y, desty) - math.min(y, desty)
    local emCost = dx + dy
    
    n.mCost = n.mCost + fromnode.mCost
    n.score = n.mCost + emCost
    n.parent = fromnode
    
    return n
  end
  
  return nil
end
