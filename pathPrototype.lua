local rotationTools = require "rotationTools"


local pathPrototype = {}

local function path_addLine(self, rotation, magnitude)
   local subpath = {
      type = "Absolute",
      magnitude = magnitude
   }
   subpath.xDir, subpath.yDir = rotationTools:getVectorFromRotation(rotation)

   table.insert(self.subpaths, subpath)
end

local function path_addRelativeLine(self, rotation, magnitude)
   local subpath = {
      type = "Relative",
      magnitude = magnitude,
      rotation = rotation
   }

   table.insert(self.subpaths, subpath)
end

function pathPrototype.create(self)
   local path = {
      subpaths = {},

      addLine = path_addLine,
      addRelativeLine = path_addRelativeLine
   }

   return path
end

return pathPrototype