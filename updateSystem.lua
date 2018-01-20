local entityMapFactory = require "entityMapFactory"

--- Update Entity
-- (number: id) -- Automatically added by entityFactory
-- table: updateComponent

--- table: UpdateComponent
-- name: Update
-- function: update

local updateSystem = {
   entityMap = entityMapFactory:create() -- entityMap: Stores all update entities.
}

function updateSystem.addEntity(
   self,
   entity
)
   self.entityMap:add(entity)
   print("hi")
end

function updateSystem.removeEntity(self, id)
   self.entityMap:remove(id)
end

function updateSystem.update(self, dt)
   for __, entity in ipairs(self.entityMap:getList()) do
      entity.updateComponent.update(entity, dt)
   end
end

return updateSystem