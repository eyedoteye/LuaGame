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
   positionComponent
)
   local entity = entityFactory:createEntity({
      spriteComponent = spriteComponent,
      positionComponent = positionComponent
   })

   local index = self.spriteEntitiesSize + 1
   self.spriteEntities[index] = entity
   self.spriteEntitiesSize = self.spriteEntitiesSize + 1
   self.spriteEntityIDToIndex[entity.id] = index

   return entity.id
end

local function render(spriteComponent, positionComponent)
   love.graphics.draw(
      spriteComponent.texture,
      spriteComponent.quad,
      positionComponent.x,
      positionComponent.y
   )
end

function spriteSystem.draw(self)
   for _, spriteEntity in ipairs(self.spriteEntities) do
      render(spriteEntity.spriteComponent, spriteEntity.positionComponent)
   end
end

return spriteSystem