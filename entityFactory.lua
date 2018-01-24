local entityFactory = {
   usedIDs = {},
   namedEntities = {}
}

local function resolveCollision(usedIDs, id)
   local collisions = 1
   while collisions < 3 and usedIDs[id] ~= nil do
      --id = tostring(math.random())
      id = math.random()
      collisions = collisions + 1
   end
   if collisions == 3 then
      error("entityFactory-resolveCollision: More than 3 id collisions. Check for leak.")
   end

   return id
end

function entityFactory.createEntity(self, entityComponents)
   local entity = entityComponents

   --local id = tostring(math.random())
   local id = math.random()
   if self.usedIDs[id] ~= nil then
      id = resolveCollision(self.usedIDs, id)
   end

   entity.id = id
   return entity
end

function entityFactory.registerNamedEntity(self, entity, name)
   assert(self.namedEntities[name] == nil, "name already exists.")
   self.namedEntities[name] = entity
end

function entityFactory.unregisterNamedEntity(self, entity, name)
   assert(self.namedEntities[name] ~= nil, "name does not exist.")
   self.namedEntities[name] = nil
end

function entityFactory.getNamedEntity(self, name)
   return self.namedEntities[name]
end

function entityFactory.relieveID(self, id)
   self.usedIDs[id] = nil
end

return entityFactory