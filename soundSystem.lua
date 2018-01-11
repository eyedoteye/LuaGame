local entityFactory = require "entityFactory"
local entityListFactory = require "entityList"
local clearTable = require "clearTable"


-- Sound Entity {
--    (id),
--    soundEffectComponent,
--    positionComponent,
--    finishedCallbackComponent
--}

local soundSystem = {
   entityList = entityListFactory:create()
}

--- table: SoundEffectComponent
-- name: SoundEffect
-- userdata [Source]: source
-- table: information

--- table: PositionComponent
-- name: Position
-- number: x
-- number: y

--- table: FinishedCallbacksComponent
-- name: FinishedCallback
--- function: callback

function soundSystem.addSoundEntity(
   self,
   soundEffectComponent,
   positionComponent,
   finishedCallbackComponent
)
   if soundEffectComponent == nil then
      error("soundSystem.addSoundEntity: soundEffectComponent = nil")
   end
   -- positionComponent can be equal to nil for non-positional audio.
   -- finishedCallbackComponent can be equal to nil.

   local entity = entityFactory:createEntity({
      soundEffectComponent = soundEffectComponent,
      positionComponent = positionComponent,
      finishedCallbackComponent = finishedCallbackComponent
   })

   self.entityList:add(entity)

   return entity.id
end

function soundSystem.removeSoundEntity(self, id)
   local entity = self.entityList:get(id)
   clearTable(entity)
   self.entityList:remove(id)
end


--- Performs updates needed for maintaining sound system.
-- Updates position of all love2d Sources.
function soundSystem.update(self)
   for _, soundEntity in self.entityList:getPairs() do
      local position = soundEntity.positionComponent
      if position ~= nil then
         soundEntity.soundEffectComponent.source:setPosition(position.x, position.y)
      end

      if soundEntity.soundEffectComponent.source:isStopped() and
         soundEntity.finishedCallbackComponent ~= nil then
         soundEntity.finishedCallbackComponent.callback(soundEntity)
      end
   end
end

return soundSystem