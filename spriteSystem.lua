local entityFactory = require "entityFactory"

local spriteSystem = {
   spriteEntities = {},
   spriteEntitiesSize = 0,
   spriteEntityIDToIndex = {}
}


--- table: SpriteComponent
-- string: textureName
-- string: quadName 
-- userdata [Image]: texture
-- userdata [Quad]: quad
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

   local index = self.spriteEntitiesSize + 1
   self.spriteEntities[index] = entity
   self.spriteEntitiesSize = self.spriteEntitiesSize + 1
   self.spriteEntityIDToIndex[entity.id] = index

   return entity.id
end

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

   love.graphics.draw(
      spriteComponent.texture,
      spriteComponent.quad,
      positionComponent.x + xOffset,
      positionComponent.y + yOffset
   )
end

function spriteSystem.draw(self)
   for _, spriteEntity in ipairs(self.spriteEntities) do
      render(
         spriteEntity.spriteComponent,
         spriteEntity.positionComponent,
         spriteEntity.positionOffsetComponent)
   end
end

return spriteSystem