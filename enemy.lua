local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local collisionSystem = require "collisionSystem"

local componentFactory = require "componentFactory"

local clearTable = require "clearTable"

local function deleteEnemy(self)
   spriteSystem:removeSpriteEntity(self.spriteSystemEntityID)
   collisionSystem:removeCollisionEntity(self.collisionSystemEntityID)
end

local function resolveCollision(selfCollisionEntity, otherCollisionEntity, data)
   if otherCollisionEntity.parent.entityTypeComponent.type == "Fireball" then
      deleteEnemy(selfCollisionEntity.parent)
   end
end

local function createEnemy(x, y, rotation)
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
      )
   }

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
end

return createEnemy