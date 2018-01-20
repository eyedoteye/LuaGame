local spriteSystem = require "spriteSystem"
local updateSystem = require "updateSystem"
local spriteController = require "spriteController"

local entityFactory = require "entityFactory"
local componentFactory = require "componentFactory"



local function update(self, dt)
   local x, y = love.mouse.getPosition()
   self.positionComponent.x = x
   self.positionComponent.y = y
end

local mouse = entityFactory:createEntity({
   positionComponent = componentFactory:createComponent("Position", {}),
   updateComponent = componentFactory:createComponent("Update", {update = update}),
})

function mouse.init(self)
   print("hello")

   mouse.spriteComponent = spriteController:getSpriteComponentWithSprite(
      "player",
      "crosshair"
   )
   spriteSystem:addEntity(self)
   love.mouse.setVisible(false)

   updateSystem:addEntity(self)
end

return mouse