local entityList = {}
local function entityList_get(self, id)
   local index = self.idToIndex[id]
   if index == nil then
      return nil
   end

   return self.entities[index]
end

local function entityList_getPairs(self)
   return ipairs(self.entities)
end

local function entityList_add(self, entity)
   local index = self.size + 1
   self.entities[index] = entity
   self.size = self.size + 1
   self.idToIndex[entity.id] = index
end

local function entityList_remove(self, id)
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

function entityList.create(self)
   local list = {
      entities = {},
      size = 0,
      idToIndex = {},

      get = entityList_get,
      getPairs = entityList_getPairs,
      add = entityList_add,
      remove = entityList_remove
   }
   return list
end

return entityList
