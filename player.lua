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
   ),
   rotationComponent = componentFactory:createComponent(
      "Rotation",
      {
         rotation = 180
      }
   )
}
function player.load(self)
   self.idleSprite = {}
   self.idleSprite.spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "idle"
   )

   self.spriteSystemEntityID = spriteSystem:addSpriteEntity(
      self.idleSprite.spriteComponent,
      self.positionComponent,
      nil,
      self.rotationComponent
   )
end
local function processMovementInput(self, dt)
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
local function processMouseMovementInput(self)
   local mouseX, mouseY = love.mouse.getPosition()
   local xOffset = mouseX - self.positionComponent.x
   local yOffset = mouseY - self.positionComponent.y
   self.rotationComponent.rotation = math.atan2(xOffset, -yOffset) / math.pi * 180
end
function player.update(self, dt)
   processMovementInput(self, dt)
   processMouseMovementInput(self)
end

return player