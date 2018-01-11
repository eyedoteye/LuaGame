local entityFactory = require "entityFactory"
local clearTable = require "clearTable"



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
-- @param components table: Table containing mapped components of entity.
local function entityMap_createAndAddEntity(self, components)
   local entity = entityFactory:createEntity(components)

   local index = self.size + 1
   self.entities[index] = entity
   self.size = self.size + 1
   self.idToIndex[entity.id] = index

   return entity.id
end

--- Removes an entity from the map.
-- @param id string: This map's ID of the entity to be removed.
local function entityMap_remove(self, id)
   local index = self.idToIndex[id]
   if index == nil then
      error("entityMap_remove: id does not exist in map.")
   end

   local entity = self.entities[index]
   clearTable(entity)

   if self.size > 1 and index ~= self.size then
      local replacementEntity = self.entities[self.size]
      self.entities[self.size] = nil

      self.idToIndex[replacementEntity.id] = index
      self.entities[index] = replacementEntity
   else
      self.entities[index] = nil
   end

   self.idToIndex[id] = nil
   entityFactory:relieveID(id)

   self.size = self.size - 1
end

--- Creates a new entityMap.
-- Allows fast iteration over a list while allowing entities to be removed by id.
-- @return entityMap: A new entityMap.
function entityMapFactory.create(self)
   local list = {
      entities = {},
      size = 0,
      idToIndex = {},

      get = entityMap_get,
      getList = entityMap_getList,
      getSize = entityMap_getSize,
      createAndAddEntity = entityMap_createAndAddEntity,
      remove = entityMap_remove
   }
   return list
end

return entityMapFactory