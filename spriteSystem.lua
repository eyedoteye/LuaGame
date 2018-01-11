local entityFactory = require "entityFactory"
local entityMapFactory = require "entityMapFactory"
local clearTable = require "clearTable"

local spriteSystem = {
   entityMap = entityMapFactory:create()
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

   self.entityMap:add(entity)

   return entity.id
end

function spriteSystem.removeSpriteEntity(self, id)
   local entity = self.entityMap:get(id)
   clearTable(entity)
   self.entityMap:remove(id)
end

function spriteSystem.hasSpriteEntity(self, id)
   return self.entityMap:get(id) ~= nil
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
   for _, spriteEntity in self.entityMap:getPairs() do
      render(
         spriteEntity.spriteComponent,
         spriteEntity.positionComponent,
         spriteEntity.positionOffsetComponent)
   end
end

return spriteSystem