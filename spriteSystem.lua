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
function spriteSystem.addEntity(
   self,
   entity
)
   self.entityMap:add(entity)
end

--- Removes a spriteEntity from the sprite system.
-- @param id string: This system's ID of the entity to remove.
function spriteSystem.removeEntity(self, id)
   self.entityMap:remove(id)
end

--- Checks to see if a spriteEntity exists within this system by ID.
-- @param id string: This system's ID of the entity to check for.
-- @return bool: Whether the entity exists in this system or not.
function spriteSystem.hasEntity(self, id)
   return self.entityMap:get(id) ~= nil
end

--- Renders all spriteEntitys.
local function render(
   spriteComponent,
   positionComponent,
   rotationComponent,
   originOffsetComponent
)
   local rotation = 0
   if rotationComponent ~= nil then
      rotation = rotationComponent.rotation
   end
   local originXOffset, originYOffset = 0, 0
   if originOffsetComponent ~= nil then
      originXOffset = originOffsetComponent.x
      originYOffset = originOffsetComponent.y
   end
   local _, _, width, height = spriteComponent.quad:getViewport()
   local originX = width / 2
   local originY = height / 2

   -- Intentional mutation of non-standard global variable 'love'
   -- Implementation of love2d v0.10.2 api:
   --    https://love2d.org/w/index.php?title=love.graphics.draw&oldid=20895
   love.graphics.draw(
      spriteComponent.texture,
      spriteComponent.quad,
      math.floor(positionComponent.x),
      math.floor(positionComponent.y),
      rotation * math.pi / 180,
      1, 1,
      math.floor(originX + originXOffset),
      math.floor(originY + originYOffset)
   )
end

--- Renders all spriteEntitys.
function spriteSystem.draw(self)
   for _, entity in ipairs(self.entityMap:getList()) do
      if not entity.spriteComponent.hidden then
         render(
            entity.spriteComponent,
            entity.positionComponent,
            entity.rotationComponent,
            entity.originOffsetComponent
         )
      end
   end
end

return spriteSystem