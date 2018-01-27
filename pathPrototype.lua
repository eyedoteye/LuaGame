local rotationTools = require "rotationTools"


local pathPrototype = {}

local function path_addLine(self, rotation, magnitude)
   local subpath = {
      magnitude = magnitude
   }
   subpath.xDir, subpath.yDir = rotationTools:getVectorFromRotation(rotation)

   table.insert(self.subpaths, subpath)
end

function pathPrototype.create(self)
   local path = {
      subpaths = {},

      addLine = path_addLine
   }

   return path
end

return pathPrototype