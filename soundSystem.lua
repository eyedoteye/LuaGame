local entityMapFactory = require "entityMapFactory"



--- Sound Entity
-- (number: id) -- Automatically added by entityFactory
-- table: soundEffectComponent
-- table: positionComponent
-- table: finishedCallbackComponent

--- table: SoundEffectComponent
-- name: SoundEffect
-- userdata [Source]: source
-- table: information

--- table: PositionComponent
-- name: Position
-- number: x
-- number: y

--- table: FinishedCallbackComponent
-- name: FinishedCallback
--- function: callback

local soundSystem = {
   entityMap = entityMapFactory:create() -- entityMap: Stores all soundEntities.
}

--- Adds a soundEntity to the sound system.
-- @param soundEffectComponent soundEffectComponent: Sound effect to play of entity.
-- @param positionComponent positionComponent: Position of entity.
-- @param finishedCallbackComponent finishedCallbackComponent: Function to call after sound effect has finished.
-- @return number: This system's ID of the soundEntity.
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

   local id = self.entityMap:createAndAddEntity({
      soundEffectComponent = soundEffectComponent,
      positionComponent = positionComponent,
      finishedCallbackComponent = finishedCallbackComponent
   })

   return id
end

--- Removes a soundEntity from the sound system.
-- @param id string: This system's ID of the entity to remove.
function soundSystem.removeSoundEntity(self, id)
   self.entityMap:remove(id)
end

--- Performs updates needed for maintaining sound system.
-- Updates position of all love2d Sources.
function soundSystem.update(self)
   for _, soundEntity in ipairs(self.entityMap:getList()) do
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