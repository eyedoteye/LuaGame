local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local collisionSystem = require "collisionSystem"
local updateSystem = require "updateSystem"

local entityFactory = require "entityFactory"
local componentFactory = require "componentFactory"
local rotationTools = require "rotationTools"

local function delete(self)
   spriteSystem:removeEntity(self.id)
   collisionSystem:removeEntity(self.id)
   updateSystem:removeEntity(self.id)
end

local function resolveCollision(self, other, data)
   if other.entityTypeComponent.type == "Fireball" then
      delete(self)
   end
end

local function update(self)
   self.rotationComponent.rotation = rotationTools:getRotationFromPointToPoint(
      self.positionComponent.x, self.positionComponent.y,
      self.playerPositionComponent.x, self.playerPositionComponent.y
   )
end

local enemyPrototype = {}

function enemyPrototype.create(
   self,
   x, y,
   rotation,
   playerPositionComponent
)
   local enemy = entityFactory:createEntity({
      entityTypeComponent = componentFactory:createComponent(
         "EntityType",
         {
            type = "Enemy"
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
      colliderComponent = componentFactory:createComponent(
         "Collider.Circle",
         {
            radius = 14,
            resolveCollision = resolveCollision
         }
      ),
      updateComponent = componentFactory:createComponent(
         "Update",
         {
            update = update
         }
      ),
      spriteComponent = spriteController:getSpriteComponentWithSprite(
         "player",
         "enemy"
      )
   })
   enemy.playerPositionComponent = playerPositionComponent

   spriteSystem:addEntity(enemy)
   collisionSystem:addEntity(enemy)
   updateSystem:addEntity(enemy)

   return enemy
end

return enemyPrototype 