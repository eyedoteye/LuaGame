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


local mousePrototype = {}

function mousePrototype.create()
   local mouse = entityFactory:createEntity({
      positionComponent = componentFactory:createComponent("Position", {}),
      updateComponent = componentFactory:createComponent("Update", {update = update}),
      spriteComponent = spriteController:getSpriteComponentWithSprite(
         "player",
         "crosshair"
      )
   })

   spriteSystem:addEntity(mouse)
   updateSystem:addEntity(mouse)

   love.mouse.setVisible(false)
   return mouse
end

return mousePrototype