local spriteSystem = require "spriteSystem"
local updateSystem = require "updateSystem"
local spriteController = require "spriteController"

local componentFactory = require "componentFactory"



local function updateCrosshair(self)
   local x, y = love.mouse.getPosition()
   self.positionComponent.x = x
   self.positionComponent.y = y
end

local function update(updateEntity, dt)
   updateCrosshair(updateEntity.parent)
end

local mouse = {
   positionComponent = componentFactory:createComponent("Position", {}),
   updateComponent = componentFactory:createComponent("Update", {update = update})
}

function mouse.load(self)
   self.crosshairSprite = {}
   self.crosshairSprite.spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "crosshair"
   )

   self.spriteSystemEntityID = spriteSystem:addSpriteEntity(
      self.crosshairSprite.spriteComponent,
      self.positionComponent
   )
   love.mouse.setVisible(false)

   self.updateSystemEntityID = updateSystem:addUpdateEntity(
      self.updateComponent,
      self
   )
end

function mouse.update(self, dt)
   local x, y = love.mouse.getPosition()
   self.positionComponent.x = x
   self.positionComponent.y = y
end

return mouse