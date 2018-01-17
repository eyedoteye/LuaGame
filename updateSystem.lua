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

function updateSystem.addUpdateEntity(
   self,
   updateComponent,
   parent
)
   local id = self.entityMap:createAndAddEntity({
      updateComponent = updateComponent,
      parent = parent
   })

   return id
end

function updateSystem.removeUpdateEntity(self, id)
   self.entityMap:remove(id)
end

function updateSystem.update(self, dt)

   for __, updateEntity in ipairs(self.entityMap:getList()) do
      updateEntity.updateComponent.update(updateEntity, dt)
   end
end

return updateSystem