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
   collisionSystem:removeCollisionEntity(self.collisionSystemEntityID)
--   clearTable(self.updateComponent)
--   clearTable(self.positionComponent)
--   clearTable(self.rotationComponent)
--   clearTable(self.fireballSprite)
--   clearTable(self)
end

local function fireball_resolveCollision(selfCollisionEntity, otherCollisionEntity, data)
   if otherCollisionEntity.parent.entityTypeComponent.type == "Enemy" then
      fireball_delete(selfCollisionEntity.parent)
   end
end

local function fireball_update(updateEntity, dt)
   local self = updateEntity.parent
   fireball_moveForward(self, dt)
   self.lifetime = self.lifetime - dt
   if self.lifetime <= 0 then
      fireball_delete(self)
   end
end

local function fireball_init(self)
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
   self.collisionSystemEntityID = collisionSystem:addCollisionEntity(
      self.entityTypeComponent,
      self.positionComponent,
      self.colliderComponent,
      self
   )
   self.lifetime = 1
end

local function fireball_create(
   x, y,
   rotation
)
   local fireball = {
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
            update = fireball_update
         }
      ),
      colliderComponent = componentFactory:createComponent(
         "Collider.Circle",
         {
            radius = 8,
            resolveCollision = fireball_resolveCollision
         }
      )
   }
   fireball_init(fireball)
end