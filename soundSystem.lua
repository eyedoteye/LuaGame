local componentFactory = require "componentFactory"
local entityFactory = require "entityFactory"

local function clearTable(table)
   for key in pairs(table) do
      table[key] = nil
   end
end

love.audio.setPosition(love.graphics.getDimensions() / 2, 100)
love.audio.setDistanceModel("linearclamped")

local soundController = {
   soundSources = {},
   soundSystem = nil -- Set at end of file.
}



local sourcePool = {}

--- Creates a source pool. Holds multiple clones of the same source.
-- @param source [userdata]
function sourcePool.create(self, source)
  local pool = {
     original = source,
     sources = {},
     size = 0,
     largestSize = 0
  }
  return pool
end

--- Gets a Love2D source from the pool.
-- @return source [userdata]: Clone of original Love2D Source.
function sourcePool.get(self, pool)
   if pool.size == 0 then
      return pool.original:clone()
   end

   local source = pool.sources[pool.size]
   pool.size = pool.size - 1
   return source
end

--- Returns a sound source back into the pool. 
-- @param source [userdata]: Love2D Source to return to pool.
function sourcePool.returnSource(self, pool, source)
   pool.sources[pool.size + 1] = source
   pool.size = pool.size + 1
   if pool.size > pool.largestSize then
      pool.largestSize = pool.size
      print("Largest pool size: ".. pool.largestSize)
   end
end



-- Will request a sound source from a clone pool when asset manager is added.
local function getSoundSource(soundName)
   return sourcePool:get(soundController.soundSources[soundName])
end

-- Temporary way to add sound sources until asset manager is added.
function soundController.addSoundSource(self, soundFilePath, soundName)
   if self.soundSources[soundName] == nil then
      -- Intentional mutation of non-standard global variable 'love'
      -- Implementation of love2d v0.10.2 api:
      --    https://love2d.org/w/index.php?title=love.audio.newSource&oldid=15872
      source = love.audio.newSource(soundFilePath, "static")
      self.soundSources[soundName] = sourcePool:create(source)
   end
end

function soundController.playSoundAttachedToPositionComponent(
   self,
   soundName,
   positionComponent
)
   local soundEffectComponent = componentFactory:createComponent("SoundEffect", {
      source = getSoundSource(soundName),
      soundName = soundName
   })
   self.soundSystem:addSoundEntity(soundEffectComponent, positionComponent)

   soundEffectComponent.source:setPosition(positionComponent.x, positionComponent.y)
   soundEffectComponent.source:play()
end

function soundController.playSound(self, soundName)
   local soundEffectComponent = componentFactory:createComponent("SoundEffect", {
      source = getSoundSource(soundName),
      soundName = soundName
   })
   self.soundSystem:addSoundEntity(soundEffectComponent)

   local width, height = love.graphics.getDimensions()
   soundEffectComponent.source:setPosition(width / 2, height / 2)
   soundEffectComponent.source:play()
end

local function informSoundControllerAboutStoppedSound(soundEntity)
   print("soundEffect: " .. soundEntity.soundEffectComponent.soundName .. " has stopped.")

   local pool = soundController.soundSources[soundEntity.soundEffectComponent.soundName]
   sourcePool:returnSource(pool, soundEntity.soundEffectComponent.source)
   clearTable(soundEntity.soundEffectComponent)
   soundController.soundSystem:removeSoundEntity(soundEntity.id)
end



-- Sound Entity {(id), soundEffectComponent, positionComponent}

local soundSystem = {
   soundEntities = {},
   soundEntitiesSize = 0,
   soundEntityIDToIndex = {}
}

--- table: SoundEffectComponent
-- name: SoundEffect
-- table [Source]: source
-- table: information

-- table: PositionComponent
-- name: Position
-- number: x
-- number: y

function soundSystem.addSoundEntity(
   self,
   soundEffectComponent,
   positionComponent
)
   local entity = entityFactory:createEntity({
      soundEffectComponent = soundEffectComponent,
      positionComponent = positionComponent
   })

   local index = self.soundEntitiesSize + 1
   self.soundEntities[index] = entity
   self.soundEntitiesSize = self.soundEntitiesSize + 1
   self.soundEntityIDToIndex[entity.id] = index

   return entity.id
end

function soundSystem.removeSoundEntity(self, id)
   local index = self.soundEntityIDToIndex[id]
   local entity = self.soundEntities[index]

   clearTable(entity)

   if self.soundEntitiesSize > 1 and index ~= self.soundEntitiesSize then
      local replacementEntity = self.soundEntities[self.soundEntitiesSize]
      self.soundEntities[self.soundEntitiesSize] = nil

      self.soundEntityIDToIndex[replacementEntity.id] = index
      self.soundEntities[index] = replacementEntity
   else
      self.soundEntities[index] = nil
   end


   self.soundEntityIDToIndex[id] = nil

   self.soundEntitiesSize = self.soundEntitiesSize - 1
end


--- Performs updates needed for maintaining sound system.
-- Updates position of all love2d Sources.
function soundSystem.update(self)
   for _, soundEntity in ipairs(self.soundEntities) do
      local position = soundEntity.positionComponent
      if position ~= nil then
         soundEntity.soundEffectComponent.source:setPosition(position.x, position.y)
      end

      if soundEntity.soundEffectComponent.source:isStopped() then
         informSoundControllerAboutStoppedSound(soundEntity)
      end
   end
end


soundController.soundSystem = soundSystem
return soundController