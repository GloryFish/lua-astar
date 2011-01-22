-- 
--  astar.lua
--  lua-astar
--  
--  Based on John Eriksson's Python A* implementation.
--  http://www.pygame.org/project-AStar-195-.html
--
--  Created by Jay Roberts on 2011-01-08.
--  Copyright 2011 Jay Roberts All rights reserved.
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

require 'middleclass'
Path = class('Path')
function Path:initialize(nodes, totalCost)
  self.nodes = nodes
  self.totalCost = totalCost
end

function Path:getNodes()
  return self.nodes
end

function Path:getTotalMoveCost()
  return self.totalCost
end

Node = class('Node')
function Node:initialize(location, mCost, lid, parent)
  self.location = location -- Where is the node located
  self.mCost = mCost -- Total move cost to reach this node
  self.parent = parent -- Parent node
  self.score = 0 -- Calculated score for this node
  self.lid = lid -- set the location id - unique for each location in the map
end

function Node.__eq(a, b)
  return a.lid == b.lid
end

AStar = class('AStar')
function AStar:initialize(maphandler) 
  self.mh = maphandler
end

function AStar:_getBestOpenNode()
  local bestNode = nil
  
  for lid, n in pairs(self.open) do
    if bestNode == nil then
      bestNode = n
    else
      if n.score <= bestNode.score then
        bestNode = n
      end
    end
  end
  
  return bestNode
end

function AStar:_tracePath(n)
  local nodes = {}
  local totalCost = n.mCost
  local p = n.parent
  
  table.insert(nodes, 1, n)
  
  while true do
    if p.parent == nil then
      break
    end
    table.insert(nodes, 1, p)
    p = p.parent
  end
  
  return Path(nodes, totalCost)
end

function AStar:_handleNode(node, goal)
  self.open[node.lid] = nil
  self.closed[node.lid] = node.lid
  
  assert(node.location ~= nil, 'About to pass a node with nil location to getAdjacentNodes')
  
  local nodes = self.mh:getAdjacentNodes(node, goal)

  for lid, n in pairs(nodes) do repeat
    if self.mh:locationsAreEqual(n.location, goal) then
      return n
    elseif self.closed[n.lid] ~= nil then -- Alread in close, skip this
      break
    elseif self.open[n.lid] ~= nil then -- Already in open, check if better score   
      local on = self.open[n.lid]
    
      if n.mCost < on.mCost then
        self.open[n.lid] = nil
        self.open[n.lid] = n
      end
    else -- New node, append to open list
      self.open[n.lid] =  n
    end
  until true end
  
  return nil
end

function AStar:findPath(fromlocation, tolocation)
  self.open = {}
  self.closed = {}
  
  local goal = tolocation
  local fnode = self.mh:getNode(fromlocation)

  local nextNode = nil

  if fnode ~= nil then
    self.open[fnode.lid] = fnode
    nextNode = fnode
  end  
  
  while nextNode ~= nil do
    local finish = self:_handleNode(nextNode, goal)
    
    if finish then
      return self:_tracePath(finish)
    end
    nextNode = self:_getBestOpenNode()
  end
  
  return nil
end
