local entityFactory = require "entityFactory"
local clearTable = require "clearTable"



-- Sound Entity {
--    (id),
--    soundEffectComponent,
--    positionComponent,
--    finishedCallbackComponent
--}

local soundSystem = {
   soundEntities = {},
   soundEntitiesSize = 0,
   soundEntityIDToIndex = {},
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

   local index = self.soundEntitiesSize + 1
   self.soundEntities[index] = entity
   self.soundEntitiesSize = self.soundEntitiesSize + 1
   self.soundEntityIDToIndex[entity.id] = index

   return entity.id
end

function soundSystem.removeSoundEntity(self, id)
   local index = self.soundEntityIDToIndex[id]
   local entity = self.soundEntities[index]

   clearTable(entity)

   if self.soundEntitiesSize > 1 and index ~= self.soundEntitiesSize then
      local replacementEntity = self.soundEntities[self.soundEntitiesSize]
      self.soundEntities[self.soundEntitiesSize] = nil

      self.soundEntityIDToIndex[replacementEntity.id] = index
      self.soundEntities[index] = replacementEntity
   else
      self.soundEntities[index] = nil
   end

   self.soundEntityIDToIndex[id] = nil

   self.soundEntitiesSize = self.soundEntitiesSize - 1
end


--- Performs updates needed for maintaining sound system.
-- Updates position of all love2d Sources.
function soundSystem.update(self)
   for _, soundEntity in ipairs(self.soundEntities) do
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