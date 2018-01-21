local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"

local entityFactory = require "entityFactory"
local componentFactory = require "componentFactory"

local playerHealthBarBlipPrototype = {}

local function deleteBlip(self)
   spriteSystem:removeEntity(self.id)
end

function playerHealthBarBlipPrototype.create(self, x, y, anchorIsTopLeft)
   assert(type(x) == "number", "x must be a number")
   assert(type(y) == "number", "y must be a number")
   assert(anchorIsTopLeft == nil or type(anchorIsTopLeft) == "boolean", "anchorIsTopLeft must be nil or a bool") 

   local spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "healthBarBlip"
   )
   local offset = {
      x = 0,
      y = 0
   }
   if anchorIsTopLeft then
      _, _, w, h = spriteComponent.quad:getViewport()
      offset.x = w / 2
      offset.y = h / 2
   end

   local blip = entityFactory:createEntity({
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = x + offset.x,
            y = y + offset.y
         }
      ),
      spriteComponent = spriteComponent
   })

   spriteSystem:addEntity(blip)

   return blip
end

local playerHealthBarPrototype = {}

local function addBlip(self)
   assert(#self.blips <= 17, "Blip count exceeds available blip slots.")
   if #self.blips == 17 then
      return
   end

   local _, _, w, h = self.spriteComponent.quad:getViewport()
   local spriteOrigin = {
      x = w / 2,
      y = h / 2
   }
   local startOffset = {
      x = 2,
      y = 2
   }
   local spaceBetweenBlips = 5
   table.insert(self.blips, playerHealthBarBlipPrototype:create(
      self.positionComponent.x - spriteOrigin.x + startOffset.x + #self.blips * spaceBetweenBlips,
      self.positionComponent.y - spriteOrigin.y + startOffset.y,
      true
   ))
end

local function addBlips(self, count)
   if count + #self.blips > 17 then
      count = 17 - #self.blips
   end

   for _ = 1, count do
      addBlip(self)
   end
end

local function removeBlip(self)
   assert(#self.blips >= 0, "Blip count is less than 0.")
   if #self.blips == 0 then
      return
   end

   deleteBlip(table.remove(self.blips))
end

local function removeBlips(self,count)
   if #self.blips - count < 0 then
      count = #self.blips
   end

   for i = 1, count do
      removeBlip(self)
   end
end

function playerHealthBarPrototype.create(self)
   local spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "healthBar"
   )
   local _, _, w, h = spriteComponent.quad:getViewport()
   local spriteOrigin = {
      x = w / 2,
      y = h / 2
   }

   local healthBar = entityFactory:createEntity({
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = spriteOrigin.x + 0,
            y = spriteOrigin.y + 0
         }
      ),
      spriteComponent = spriteComponent
   })

   spriteSystem:addEntity(healthBar)

   healthBar.blips = {}
   addBlips(healthBar, 17)
   removeBlips(healthBar, 7)

   return healthBar
end

return playerHealthBarPrototype