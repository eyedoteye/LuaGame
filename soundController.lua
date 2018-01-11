local componentFactory = require "componentFactory"
local soundSystem = require "soundSystem"
local sourcePoolFactory = require "sourcePoolFactory"
local clearTable = require "clearTable"



local soundController = {
   soundSources = {}, -- table[string] soundPool: Stores soundPools for each Source.
   soundSystem = soundSystem -- soundSystem: Updates and tracks sounds.
}

--- Grabs a Source from its pool.
-- @param soundName: Name of sound Source.
-- @return userdata [Source]: Love2D Source of requested sound.
local function getSoundSource(soundName)
   return soundController.soundSources[soundName]:get()
end

--- Returns clone of Source to its pool.
-- @param soundEntity: Entity with the desired Source to repool.
local function repoolFinishedSound(soundEntity)
   print("soundEffect: " .. soundEntity.soundEffectComponent.soundName .. " has stopped.")

   local pool = soundController.soundSources[soundEntity.soundEffectComponent.soundName]
   pool:returnSource(soundEntity.soundEffectComponent.source)

   clearTable(soundEntity.soundEffectComponent)
   clearTable(soundEntity.finishedCallbackComponent)
   soundController.soundSystem:removeSoundEntity(soundEntity.id)
end

--- Temporary way to add sound sources until asset manager is added.
-- @param soundFilePath: Relative path to sound file.
-- @param soundName: Desired name for the sound.
function soundController.addSoundSource(self, soundFilePath, soundName)
   if self.soundSources[soundName] == nil then
      -- Intentional mutation of non-standard global variable 'love'
      -- Implementation of love2d v0.10.2 api:
      --    https://love2d.org/w/index.php?title=love.audio.newSource&oldid=15872
      local source = love.audio.newSource(soundFilePath, "static")
      self.soundSources[soundName] = sourcePoolFactory:create(source)
   end
end

--- Plays a sound attached to an updatable position given by a positionComponent.
-- Only mono sounds are affected by a position.
-- @param soundName: Name of the desired sound to play.
-- @param positionComponent: Updatable position to attach playing sound to.
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

--- Plays a sound with no position.
-- Note that will not convert mono sounds to stereo.
-- @param soundName: Name of desired sound to play.
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