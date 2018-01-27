local rotationTools = require "rotationTools"
local pointTools = require "pointTools"

local patherPrototype = {}

local function getSubpathDirectionVector(self, subpath)
   local xDir, yDir
   if subpath.type == "Absolute" then
      xDir = subpath.xDir
      yDir = subpath.yDir
   elseif subpath.type == "Relative" then
      local rotation = self.rotationComponent.rotation + subpath.rotation
      xDir, yDir = rotationTools:getVectorFromRotation(rotation)
   end

   return xDir, yDir
end

local function travelSubpath(self, subpath, distance)
   local xDir, yDir = getSubpathDirectionVector(self, subpath)

   self.positionComponent.x = self.positionComponent.x + distance * xDir
   self.positionComponent.y = self.positionComponent.y + distance * yDir
end

local function pather_travelPath(self, distanceToTravel)
   local subpath = self.path.subpaths[self.currentSubpath]

   if subpath == nil then -- No more subpaths to follow.
      return
   end

   local remainingDistanceOnSubpath = subpath.magnitude - self.distanceTraveledOnSubpath

   while subpath ~= nil and remainingDistanceOnSubpath < distanceToTravel do
      travelSubpath(self, subpath, remainingDistanceOnSubpath)

      distanceToTravel = distanceToTravel - remainingDistanceOnSubpath
      self.distanceTraveledOnSubpath = self.distanceTraveledOnSubpath +
         remainingDistanceOnSubpath

      self.currentSubpath = self.currentSubpath + 1
      subpath = self.path.subpaths[self.currentSubpath]

      if subpath ~= nil then
         remainingDistanceOnSubpath = subpath.magnitude
         self.distanceTraveledOnSubpath = 0
      end
   end

   if subpath == nil then -- Reached end of paths
      self.reachedEndOfPath = true
   else
      travelSubpath(self, subpath, distanceToTravel)

      self.distanceTraveledOnSubpath = self.distanceTraveledOnSubpath +
         distanceToTravel
   end
end

local function pather_reset(self)
   self.reachedEndOfPath = false
   self.currentSubpath = 1
   self.distanceTraveledOnSubpath = 0
end

local function pather_debugDraw(self)
   local subpath = self.path.subpaths[self.currentSubpath]

   if subpath ~= nil then
      local distanceRemainingOnSubpath = subpath.magnitude -
         self.distanceTraveledOnSubpath

      local xDir, yDir = getSubpathDirectionVector(self, subpath)

      local x = self.positionComponent.x +
         distanceRemainingOnSubpath * xDir
      local y = self.positionComponent.y +
         distanceRemainingOnSubpath * yDir

      for i = self.currentSubpath + 1, #self.path.subpaths do
         subpath = self.path.subpaths[i]

         local lastX = x
         local lastY = y

         xDir, yDir = getSubpathDirectionVector(self, subpath)
         x = x + subpath.magnitude * xDir
         y = y + subpath.magnitude * yDir

         love.graphics.setColor(255, 255, 255)
         love.graphics.line(
            lastX, lastY,
            x, y
         )
      end

      subpath = self.path.subpaths[self.currentSubpath]

      xDir, yDir = getSubpathDirectionVector(self, subpath)
      x = self.positionComponent.x +
         distanceRemainingOnSubpath * xDir
      y = self.positionComponent.y +
         distanceRemainingOnSubpath * yDir

      love.graphics.setColor(0, 255, 0)
      love.graphics.line(
         self.positionComponent.x, self.positionComponent.y,
         x, y
      )
   end
end

function patherPrototype.create(self, entity, path)
   local pather = {
      positionComponent = entity.positionComponent,
      rotationComponent = entity.rotationComponent,
      path = path,
      currentSubpath = 1,
      distanceTraveledOnSubpath = 0,

      travelPath = pather_travelPath,
      reset = pather_reset,
      debugDraw = pather_debugDraw
   }

   return pather
end

return patherPrototype
