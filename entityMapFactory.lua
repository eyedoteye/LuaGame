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
   return #self.entities
end

--- Create and add an entity to the map.
-- @param components table: Table containing mapped components of entity.
local function entityMap_createAndAddEntity(self, components)
   local entity = entityFactory:createEntity(components)

   local index = #self.entities + 1
   self.entities[index] = entity
   self.idToIndex[entity.id] = index

   return entity.id
end

--- Add an entity to the map.
--@param entity entity: Entity to add.
local function entityMap_add(self, entity)
   local index = #self.entities + 1
   self.entities[index] = entity
   self.idToIndex[entity.id] = index
end

--- Removes an entity from the map.
-- @param id string: This map's ID of the entity to be removed.
local function entityMap_remove(self, id)
   local index = self.idToIndex[id]
   if index == nil then
      error("entityMap_remove: id does not exist in map.")
   end

   --local entity = self.entities[index]
   --clearTable(entity)

   if #self.entities > 1 and index ~= #self.entities then
      local replacementEntity = self.entities[#self.entities]
      self.entities[#self.entities] = nil

      self.idToIndex[replacementEntity.id] = index
      self.entities[index] = replacementEntity
   else
      self.entities[index] = nil
   end

   self.idToIndex[id] = nil
end

--- Creates a new entityMap.
-- Allows fast iteration over a list while allowing entities to be removed by id.
-- @return entityMap: A new entityMap.
function entityMapFactory.create(self)
   local list = {
      entities = {},
      idToIndex = {},

      get = entityMap_get,
      getList = entityMap_getList,
      getSize = entityMap_getSize,
      createAndAddEntity = entityMap_createAndAddEntity,
      add = entityMap_add,
      remove = entityMap_remove
   }
   return list
end

return entityMapFactory