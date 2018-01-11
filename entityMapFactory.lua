local entityMapFactory = {}

--- Gets an entity from the map by id.
-- @param id string: Unique ID of entity in this map.
-- @return table: Entity in map, matching given ID.
local function entityMap_get(self, id)
   local index = self.idToIndex[id]
   if index == nil then
      return nil
   end

   return self.entities[index]
end

--- Gets all entities in map as an indexed list.
-- @return list: An indexed list containting all entities in the map.
local function entityMap_getList(self)
   return self.entities
end

--- Gets number of entities currently in the map.
-- @return number: An integer representing the number of entities currently in the map.
local function entityMap_getSize(self)
   return self.size
end

--- Add an entity to the map.
-- @param entity table: The entity to be added to the map.
local function entityMap_add(self, entity)
   local index = self.size + 1
   self.entities[index] = entity
   self.size = self.size + 1
   self.idToIndex[entity.id] = index
end

--- Removes an entity from the map.
-- @param id string: This map's ID of the entity to be removed.
local function entityMap_remove(self, id)
   local index = self.idToIndex[id]

   if self.size > 1 and index ~= self.size then
      local replacementEntity = self.entities[self.size]
      self.entities[self.size] = nil

      self.idToIndex[replacementEntity.id] = index
      self.entities[index] = replacementEntity
   else
      self.entities[index] = nil
   end

   self.idToIndex[id] = nil

   self.size = self.size - 1
end

--- Creates a new entityMap.
-- Allows fast iteration over a list while allowing entities to be removed by id.
-- @return table: A new entityMap.
function entityMapFactory.create(self)
   local list = {
      entities = {},
      size = 0,
      idToIndex = {},

      get = entityMap_get,
      getList = entityMap_getList,
      getSize = entityMap_getSize,
      add = entityMap_add,
      remove = entityMap_remove
   }
   return list
end

return entityMapFactory