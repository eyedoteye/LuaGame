local inputController = require "inputController"
local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local componentFactory = require "componentFactory"



local screenWidth, screenHeight = love.graphics.getDimensions()

local player = {
   positionComponent = componentFactory:createComponent(
      "Position",
      {
         x = screenWidth / 2,
         y = screenHeight / 2
      }
   ),
   colliderComponent = componentFactory:createComponent(
      "Collider.Circle",
      {
         radius = 16
      }
   )
}
function player.load(self)
   self.idleSprite = {}
   self.idleSprite.spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "idle"
   )
   local _, _, width, height = self.idleSprite.spriteComponent.quad:getViewport()
   self.idleSprite.positionOffsetComponent = componentFactory:createComponent(
      "PositionOffset",
      {
         x = -width / 2,
         y = -height / 2
      }
   )
   self.spriteSystemEntityID = spriteSystem:addSpriteEntity(
      self.idleSprite.spriteComponent,
      self.positionComponent,
      self.idleSprite.positionOffsetComponent
   )
end
local function processInput(self, dt)
   local x, y = 0, 0
   if inputController:isDown(1, "up") then
      y = y - 1
   end
   if inputController:isDown(1, "down") then
      y = y + 1
   end
   if inputController:isDown(1, "left") then
      x = x - 1
   end
   if inputController:isDown(1, "right") then
      x = x + 1
   end
   local speed = 100
   self.positionComponent.x = self.positionComponent.x + x * speed * dt
   self.positionComponent.y = self.positionComponent.y + y * speed * dt
end
function player.update(self, dt)
   processInput(self, dt)
end

return player