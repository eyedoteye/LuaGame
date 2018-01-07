local componentFactory = require "componentFactory"
local soundSystem = require "soundSystem"

local function clearTable(table)
   for key in pairs(table) do
      table[key] = nil
   end
end


-- TODO: Move sourcePool closer to asset manager.
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



local soundController = {
   soundSources = {},
   soundSystem = soundSystem
}

-- TODO: Move sourcePool closer to asset manager.
local function getSoundSource(soundName)
   return sourcePool:get(soundController.soundSources[soundName])
end

local function repoolFinishedSound(soundEntity)
   print("soundEffect: " .. soundEntity.soundEffectComponent.soundName .. " has stopped.")

   local pool = soundController.soundSources[soundEntity.soundEffectComponent.soundName]
   sourcePool:returnSource(pool, soundEntity.soundEffectComponent.source)
   clearTable(soundEntity.soundEffectComponent)
   clearTable(soundEntity.finishedCallbackComponent)
   soundController.soundSystem:removeSoundEntity(soundEntity.id)
end

-- Temporary way to add sound sources until asset manager is added.
function soundController.addSoundSource(self, soundFilePath, soundName)
   if self.soundSources[soundName] == nil then
      -- Intentional mutation of non-standard global variable 'love'
      -- Implementation of love2d v0.10.2 api:
      --    https://love2d.org/w/index.php?title=love.audio.newSource&oldid=15872
      local source = love.audio.newSource(soundFilePath, "static")
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
   local finishedCallbackComponent = componentFactory:createComponent("FinishedCallback", {
      callback = repoolFinishedSound
   })

   self.soundSystem:addSoundEntity(
      soundEffectComponent,
      positionComponent,
      finishedCallbackComponent
   )

   soundEffectComponent.source:setPosition(positionComponent.x, positionComponent.y)
   soundEffectComponent.source:play()
end

function soundController.playSound(self, soundName)
   local soundEffectComponent = componentFactory:createComponent("SoundEffect", {
      source = getSoundSource(soundName),
      soundName = soundName
   })
   local finishedCallbackComponent = componentFactory:createComponent("FinishedCallback", {
      callback = repoolFinishedSound
   })

   self.soundSystem:addSoundEntity(
      soundEffectComponent,
      nil,
      finishedCallbackComponent
   )

   -- Intentional mutation of non-standard global variable 'love'
   -- Implementation of love2d v0.10.2 api:
   --    https://love2d.org/w/index.php?title=love.graphics.getDimensions&oldid=13028
   local width, height = love.graphics.getDimensions()
   soundEffectComponent.source:setPosition(width / 2, height / 2)
   soundEffectComponent.source:play()
end



-- Intentional mutation of non-standard global variable 'love'
-- Implementation of love2d v0.10.2 api:
--    https://love2d.org/w/index.php?title=love.graphics.getDimensions&oldid=13028
local width, height = love.graphics.getDimensions()
-- Intentional mutation of non-standard global variable 'love'
-- Implementation of love2d v0.10.2 api:
--    https://love2d.org/w/index.php?title=love.audio.setPosition&oldid=9729
love.audio.setPosition(width / 2, height / 2, 100)
-- Intentional mutation of non-standard global variable 'love'
-- Implementation of love2d v0.10.2 api:
--    https://love2d.org/w/index.php?title=love.audio.setDistanceModel&oldid=8411
love.audio.setDistanceModel("linearclamped")



return soundController