local entityMapFactory = {}
local function entityMap_get(self, id)
   local index = self.idToIndex[id]
   if index == nil then
      return nil
   end

   return self.entities[index]
end

local function entityMap_getPairs(self)
   return ipairs(self.entities)
end

local function entityMap_add(self, entity)
   local index = self.size + 1
   self.entities[index] = entity
   self.size = self.size + 1
   self.idToIndex[entity.id] = index
end

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

function entityMapFactory.create(self)
   local list = {
      entities = {},
      size = 0,
      idToIndex = {},

      get = entityMap_get,
      getPairs = entityMap_getPairs,
      add = entityMap_add,
      remove = entityMap_remove
   }
   return list
end

return entityMapFactory