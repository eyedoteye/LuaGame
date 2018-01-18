local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local collisionSystem = require "collisionSystem"
local updateSystem = require "updateSystem"

local componentFactory = require "componentFactory"
local rotationTools = require "rotationTools"

local function deleteEnemy(self)
   spriteSystem:removeSpriteEntity(self.spriteSystemEntityID)
   collisionSystem:removeCollisionEntity(self.collisionSystemEntityID)
   updateSystem:removeUpdateEntity(self.updateSystemEntityID)
end

local function resolveCollision(selfCollisionEntity, otherCollisionEntity, data)
   if otherCollisionEntity.parent.entityTypeComponent.type == "Fireball" then
      deleteEnemy(selfCollisionEntity.parent)
   end
end

local function update(selfUpdateEntity)
   local self = selfUpdateEntity.parent
   self.rotationComponent.rotation = rotationTools:getRotationFromPointToPoint(
      self.positionComponent.x, self.positionComponent.y,
      self.playerPositionComponent.x, self.playerPositionComponent.y
   )
end

local function createEnemy(
   x, y,
   rotation,
   playerPositionComponent
)
   local enemy = {
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
            radius = 16,
            resolveCollision = resolveCollision
         }
      ),
      updateComponent = componentFactory:createComponent(
         "Update",
         {
            update = update
         }
      )
   }
   enemy.playerPositionComponent = playerPositionComponent

   enemy.idleSprite = spriteController:getSpriteComponentWithSprite(
      "player",
      "enemy"
   )

   enemy.spriteSystemEntityID = spriteSystem:addSpriteEntity(
      enemy.idleSprite,
      enemy.positionComponent,
      nil,
      enemy.rotationComponent
   )
   enemy.collisionSystemEntityID = collisionSystem:addCollisionEntity(
      enemy.entityTypeComponent,
      enemy.positionComponent,
      enemy.colliderComponent,
      enemy
   )
   enemy.updateSystemEntityID = updateSystem:addUpdateEntity(
      enemy.updateComponent,
      enemy
   )
end

return createEnemy