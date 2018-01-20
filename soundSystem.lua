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
function soundSystem.addEntity(
   self,
   entity
)
   assert(type(entity.soundEffectComponent) == "table", "soundEffectComponent must be a soundEffectComponent.")
   assert(entity.soundEffectComponent.name == "SoundEffect", "soundEffectComponent must be a soundEffectComponent.")
   -- positionComponent can be equal to nil for non-positional audio.
   -- finishedCallbackComponent can be equal to nil.

   self.entityMap:add(entity)
end

--- Removes a soundEntity from the sound system.
-- @param id string: This system's ID of the entity to remove.
function soundSystem.removeEntity(self, id)
   self.entityMap:remove(id)
end

--- Performs updates needed for maintaining sound system.
-- Updates position of all love2d Sources.
function soundSystem.update(self)
   for _, entity in ipairs(self.entityMap:getList()) do
      local position = entity.positionComponent
      if position ~= nil then
         entity.soundEffectComponent.source:setPosition(position.x, position.y)
      end

      if entity.soundEffectComponent.source:isStopped() and
         entity.finishedCallbackComponent ~= nil then
         entity.finishedCallbackComponent.callback(entity)
      end
   end
end

return soundSystem