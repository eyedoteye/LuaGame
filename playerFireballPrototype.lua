local spriteSystem = require "spriteSystem"
local updateSystem = require "updateSystem"
local collisionSystem = require "collisionSystem"
local spriteController = require "spriteController"
local soundController = require "soundController"

local componentFactory = require "componentFactory"
local entityFactory = require "entityFactory"

local function delete(self)
   if not self.deleted then
      spriteSystem:removeEntity(self.id)
      updateSystem:removeEntity(self.id)
      collisionSystem:removeEntity(self.id)
   end
   self.deleted = true
end

local function resolveCollision(self, other, data)
   if other.entityTypeComponent.type == "Enemy" then
      delete(self)
   end
end

local function moveForward(self, dt)
   local xDir = math.cos(self.rotationComponent.rotation * math.pi / 180)
   local yDir = math.sin(self.rotationComponent.rotation * math.pi / 180)
   local moveSpeed = 200
   self.positionComponent.x = self.positionComponent.x + xDir * moveSpeed * dt
   self.positionComponent.y = self.positionComponent.y + yDir * moveSpeed * dt
end

local function update(self, dt)
   moveForward(self, dt)
   self.lifetime = self.lifetime - dt
   if self.lifetime <= 0 then
      delete(self)
   end
end

local playerFireballPrototype = {}

function playerFireballPrototype.create(
   self,
   x, y,
   rotation
)
   local fireball = entityFactory:createEntity({
      entityTypeComponent = componentFactory:createComponent(
         "EntityType",
         {
            type = "Fireball"
         }
      ),
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = x,
            y = y
         }
      ),
      rotationComponent = componentFactory:createComponent(
         "Rotation",
         {
            rotation = rotation
         }
      ),
      updateComponent = componentFactory:createComponent(
         "Update",
         {
            update = update
         }
      ),
      colliderComponent = componentFactory:createComponent(
         "Collider.Circle",
         {
            radius = 8,
            resolveCollision = resolveCollision
         }
      ),
      spriteComponent = spriteController:getSpriteComponentWithSprite(
         "player",
         "fireball"
      )
   })

   spriteSystem:addEntity(fireball)
   updateSystem:addEntity(fireball)
   collisionSystem:addEntity(fireball)

   soundController:playSoundAttachedToPositionComponent(
      "Fireball",
      fireball.positionComponent
   )

   fireball.lifetime = 1

   return fireball
end

return playerFireballPrototype