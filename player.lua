local inputController = require "inputController"
local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local updateSystem = require "updateSystem"

local componentFactory = require "componentFactory"

local clearTable = require "clearTable"

local function fireball_moveForward(self, dt)
   local xDir = math.cos((self.rotationComponent.rotation - 90) * math.pi / 180)
   local yDir = math.sin((self.rotationComponent.rotation - 90) * math.pi / 180)
   local moveSpeed = 200
   self.positionComponent.x = self.positionComponent.x + xDir * moveSpeed * dt
   self.positionComponent.y = self.positionComponent.y + yDir * moveSpeed * dt
end

local function fireball_delete(self)
   spriteSystem:removeSpriteEntity(self.spriteSystemEntityID)
   updateSystem:removeUpdateEntity(self.updateSystemEntityID)
   clearTable(self.updateComponent)
   clearTable(self.positionComponent)
   clearTable(self.rotationComponent)
   clearTable(self.fireballSprite)
   clearTable(self)
end

local function fireball_update(updateEntity, dt)
   self = updateEntity.parent
   fireball_moveForward(self, dt)
   self.lifetime = self.lifetime - dt
   if self.lifetime <= 0 then
      fireball_delete(self)
   end
end

function fireball_init(self)
   self.fireballSprite = spriteController:getSpriteComponentWithSprite(
      "player",
      "fireball"
   )
   self.spriteSystemEntityID = spriteSystem:addSpriteEntity(
      self.fireballSprite,
      self.positionComponent,
      nil,
      self.rotationComponent
   )
   self.updateSystemEntityID = updateSystem:addUpdateEntity(
      self.updateComponent,
      self
   )
   self.lifetime = 1
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

local function shootFireball(self)
   local fireball = {
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = self.positionComponent.x,
            y = self.positionComponent.y
         }
      ),
      rotationComponent = componentFactory:createComponent(
         "Rotation",
         {
            rotation = self.rotationComponent.rotation
         }
      ),
      updateComponent = componentFactory:createComponent("Update",{update = fireball_update})
   }
   fireball_init(fireball)
end

local function update(updateEntity, dt)
   processMovementInput(updateEntity.parent, dt)
   processMouseMovementInput(updateEntity.parent)
   if inputController:isPressedThisFrame(1, "leftclick") then
      shootFireball(updateEntity.parent)
   end
end

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
   ),
   updateComponent = componentFactory:createComponent(
      "Update",
      {
         update = update
      }
   )
}
function player.init(self)
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

   self.updateSystemEntityID = updateSystem:addUpdateEntity(
      self.updateComponent,
      self
   )
end

return player