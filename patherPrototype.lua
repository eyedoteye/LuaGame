local rotationTools = require "rotationTools"
local pointTools = require "pointTools"

local patherPrototype = {}

local function pather_stepThroughPath(self, distanceToTravel)
   local subpath = self.path.subpaths[self.currentSubpath]

   if subpath == nil then -- No more subpaths to follow.
      return
   end

   local remainingDistanceOnSubpath = subpath.magnitude - self.distanceTraveledOnSubpath

   while subpath ~= nil and remainingDistanceOnSubpath < distanceToTravel do
      self.positionComponent.x = self.positionComponent.x +
         remainingDistanceOnSubpath * subpath.xDir
      self.positionComponent.y = self.positionComponent.y +
         remainingDistanceOnSubpath * subpath.yDir

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
      self.positionComponent.x = self.positionComponent.x +
         distanceToTravel * subpath.xDir
      self.positionComponent.y = self.positionComponent.y +
         distanceToTravel * subpath.yDir

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
      local x = self.positionComponent.x +
         distanceRemainingOnSubpath * subpath.xDir
      local y = self.positionComponent.y +
         distanceRemainingOnSubpath * subpath.yDir

      for i = self.currentSubpath + 1, #self.path.subpaths do
         subpath = self.path.subpaths[i]

         local lastX = x
         local lastY = y
         x = x + subpath.magnitude * subpath.xDir
         y = y + subpath.magnitude * subpath.yDir

         love.graphics.setColor(255, 255, 255)
         love.graphics.line(
            lastX, lastY,
            x, y
         )
      end

      subpath = self.path.subpaths[self.currentSubpath]

      x = self.positionComponent.x +
         distanceRemainingOnSubpath * subpath.xDir
      y = self.positionComponent.y +
         distanceRemainingOnSubpath * subpath.yDir

      love.graphics.setColor(0, 255, 0)
      love.graphics.line(
         self.positionComponent.x, self.positionComponent.y,
         x, y
      )
   end
end

function patherPrototype.create(self, positionComponent, path)
   local pather = {
      positionComponent = positionComponent,
      path = path,
      currentSubpath = 1,
      distanceTraveledOnSubpath = 0,

      stepThroughPath = pather_stepThroughPath,
      reset = pather_reset,
      debugDraw = pather_debugDraw
   }

   return pather
end

return patherPrototype
