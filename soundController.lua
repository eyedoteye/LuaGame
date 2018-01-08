local componentFactory = require "componentFactory"
local soundSystem = require "soundSystem"
local sourcePool = require "sourcePool"
local clearTable = require "clearTable"



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