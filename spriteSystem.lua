local entityMapFactory = require "entityMapFactory"



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

--- Adds a spriteEntity to the sprite system.
-- @param spriteComponent spriteComponent: Sprite to display of the entity.
-- @param positionComponent positionComponent: Position of the entity.
-- @param positionOffsetComponent positionOffsetComponent: How much the sprite must be shifted
--                                                         from the entity's position when displayed.
-- @return number: This system's ID of the sprite entity.
function spriteSystem.addSpriteEntity(
   self,
   spriteComponent,
   positionComponent,
   positionOffsetComponent
)
   local id = self.entityMap:createAndAddEntity({
      spriteComponent = spriteComponent,
      positionComponent = positionComponent,
      positionOffsetComponent = positionOffsetComponent
   })

   return id
end

--- Removes a spriteEntity from the sprite system.
-- @param id string: This system's ID of the entity to remove.
function spriteSystem.removeSpriteEntity(self, id)
   self.entityMap:remove(id)
end

--- Checks to see if a spriteEntity exists within this system by ID.
-- @param id string: This system's ID of the entity to check for.
-- @return bool: Whether the entity exists in this system or not.
function spriteSystem.hasSpriteEntity(self, id)
   return self.entityMap:get(id) ~= nil
end

--- Renders all spriteEntitys.
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

--- Renders all spriteEntitys.
function spriteSystem.draw(self)
   for _, spriteEntity in ipairs(self.entityMap:getList()) do
      render(
         spriteEntity.spriteComponent,
         spriteEntity.positionComponent,
         spriteEntity.positionOffsetComponent)
   end
end

return spriteSystem