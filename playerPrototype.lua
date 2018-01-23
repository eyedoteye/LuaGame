local inputController = require "inputController"
local spriteController = require "spriteController"
local spriteSystem = require "spriteSystem"
local updateSystem = require "updateSystem"
local collisionSystem = require "collisionSystem"

local componentFactory = require "componentFactory"
local entityFactory = require "entityFactory"

local playerFireballPrototype = require "playerFireballPrototype"

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
   playerFireballPrototype:create(
      self.positionComponent.x,
      self.positionComponent.y,
      self.rotationComponent.rotation
   )
end

local function setInvincible(self, on, time)
   if on then
      self.invincible = true
      self.invincibleTimer = time
      spriteController:updateSpriteComponentWithSprite(
         self.spriteComponent,
         "player",
         "invincible"
      )
   elseif self.invincible then
      self.invincible = false
      self.invincibleTimer = 0
      spriteController:updateSpriteComponentWithSprite(
         self.spriteComponent,
         "player",
         "idle"
      )
   end
end

local function update(self, dt)
   processMovementInput(self, dt)
   processMouseMovementInput(self)

   self.fireballCooldownTimer = self.fireballCooldownTimer - dt
   if self.fireballCooldownTimer < 0 then
      self.fireballCooldownTimer = 0
   end

   if inputController:isDown(1, "leftclick") then
      if self.fireballCooldownTimer == 0 then
         self.fireballCooldownTimer = self.fireballCooldown
         shootFireball(self)
      end
   end

   self.invincibleTimer = self.invincibleTimer - dt
   if self.invincibleTimer < 0 then
      setInvincible(self, false)
   end
end

local function resolveCollision(self, other, data)
   if other.entityTypeComponent.type == "Enemy" then
      if not self.invincible then
         self.healthComponent.health = self.healthComponent.health - 1
         setInvincible(self, true, 3)
      end
   end
end

local playerPrototype = {}

local maxHealth = 17

componentFactory:registerComponent(
   "Health",
   function(properties)
      local component = {
         name = "Health",
         health = properties.health
      }
      return component
   end
)

local function damage(self, value)
   assert(type(value) == "number", "value must be a number.")
   self.healthComponent.health = self.healthComponent.health - value
   if self.healthComponent.health < 0 then
      self.healthComponent.health = 0
   end
end

local function heal(self, value)
   assert(type(value) == "number", "value must be a number.")
   self.healthComponent.health = self.healthComponent.health + value
   if self.healthComponent.health > maxHealth then
      self.healthComponent.health = maxHealth
   end
end

function playerPrototype.create(self, x, y)
   assert(type(x) == "number", "x must be a number.")
   assert(type(y) == "number", "y must be a number.")

   local player = entityFactory:createEntity({
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = x,
            y = y
         }
      ),
      entityTypeComponent = componentFactory:createComponent(
         "EntityType",
         {
            type = "Player"
         }
      ),
      colliderComponent = componentFactory:createComponent(
         "Collider.Circle",
         {
            radius = 16,
            resolveCollision = resolveCollision
         }
      ),
      rotationComponent = componentFactory:createComponent(
         "Rotation",
         {
            rotation = 0
         }
      ),
      healthComponent = componentFactory:createComponent(
         "Health",
         {
            health = maxHealth
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
         "idle"
      ),

      damage = damage,
      heal = heal
   })

   spriteSystem:addEntity(player)
   updateSystem:addEntity(player)
   collisionSystem:addEntity(player)

   player.fireballCooldownTimer = 0
   player.fireballCooldown = 0.5

   player.invincibleTimer = 0

   return player
end

return playerPrototype