local entityFactory = require "entityFactory"
local entityMapFactory = require "entityMapFactory"
local clearTable = require "clearTable"



--- Sprite Entity
-- (number: id) -- Automatically added by entityFactory
-- table: spriteComponent
-- table: positionComponent
-- table: positionOffsetComponent

--- table: SpriteComponent
-- name: Sprite
-- string: textureName
-- string: quadName
-- userdata [Image]: texture
-- userdata [Quad]: quad

-- table: PositionComponent
-- name: Position
-- number: x
-- number: y

-- table: PositionOffsetComponent
-- name: PositionOffset
-- number: x
-- number: y

local spriteSystem = {
   entityMap = entityMapFactory:create() -- entityMap: Stores all sprite entities.
}

--- Adds a sprite entity to the sprite system.
-- @param spriteComponent: Sprite to display of the entity.
-- @param positionComponent: Position of the entity.
-- @param positionOffsetComponent: How much the sprite must be shifted from the entity's position when displayed.
-- @return number: This system's ID of the sprite entity.
function spriteSystem.addSpriteEntity(
   self,
   spriteComponent,
   positionComponent,
   positionOffsetComponent
)
   local entity = entityFactory:createEntity({
      spriteComponent = spriteComponent,
      positionComponent = positionComponent,
      positionOffsetComponent = positionOffsetComponent
   })

   self.entityMap:add(entity)

   return entity.id
end

--- Removes a sprite entity from the sprite system.
-- @param id: This system's ID of the entity to remove.
function spriteSystem.removeSpriteEntity(self, id)
   local entity = self.entityMap:get(id)
   if entity == nil then
      error("spriteSystem.removeSpriteEntity: id does not exist in map.")
   end
   clearTable(entity)
   self.entityMap:remove(id)
end

--- Checks to see if a sprite entity exists within this system.
-- @param id: This system's ID of the entity to check for.
-- @return bool: Whether the entity exists in this system or not.
function spriteSystem.hasSpriteEntity(self, id)
   return self.entityMap:get(id) ~= nil
end

--- Renders all sprite entities.
local function render(
   spriteComponent,
   positionComponent,
   positionOffsetComponent
)
   local xOffset, yOffset = 0, 0
   if positionOffsetComponent ~= nil then
      xOffset = positionOffsetComponent.x
      yOffset = positionOffsetComponent.y
   end

   -- Intentional mutation of non-standard global variable 'love'
   -- Implementation of love2d v0.10.2 api:
   --    https://love2d.org/w/index.php?title=love.graphics.draw&oldid=20895
   love.graphics.draw(
      spriteComponent.texture,
      spriteComponent.quad,
      positionComponent.x + xOffset,
      positionComponent.y + yOffset
   )
end

--- Renders all sprite entities.
function spriteSystem.draw(self)
   for _, spriteEntity in ipairs(self.entityMap:getList()) do
      render(
         spriteEntity.spriteComponent,
         spriteEntity.positionComponent,
         spriteEntity.positionOffsetComponent)
   end
end

return spriteSystem