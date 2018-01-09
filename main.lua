local debugMode = false
local stableMemory = true
local paused = false
local SPEED_PER_FRAME = 1 / 60
local frame = 0


local inputSystem = require "inputSystem"
local collisionSystem = require "collisionSystem"
local soundSystem = require "soundSystem"
local soundController = require "soundController"
local spriteSystem = require "spriteSystem"
local spriteController = require "spriteController"

local systems = {
   inputSystem = inputSystem,
   collisionSystem = collisionSystem,
   soundSystem = soundSystem
}

local componentFactory = require "componentFactory"
local entityFactory = require "entityFactory"



local entity1 = entityFactory:createEntity(
   {
      entityTypeComponent = componentFactory:createComponent("EntityType", {type = "Player"}),
      positionComponent = componentFactory:createComponent("Position", {x = 50, y = 50}),
      colliderComponent = componentFactory:createComponent("Collider.Circle", {radius = 10})
   }
)

local entity2 = entityFactory:createEntity(
   {
      entityTypeComponent = componentFactory:createComponent("EntityType", {type = "Ball"}),
      positionComponent = componentFactory:createComponent("Position", {x = 100, y = 50}),
      colliderComponent = componentFactory:createComponent("Collider.Circle", {radius = 10})
   }
)

collisionSystem:addCollisionEntity(
   entity1.entityTypeComponent,
   entity1.positionComponent,
   entity1.colliderComponent
)
collisionSystem:addCollisionEntity(
   entity2.entityTypeComponent,
   entity2.positionComponent,
   entity2.colliderComponent
)

collisionSystem:makeEntitiesCollidable(entity1.entityTypeComponent, entity2.entityTypeComponent)
collisionSystem:makeEntityMovableByEntity(entity2.entityTypeComponent, entity1.entityTypeComponent)

rPrint = require "rPrint"
function love.load()
   soundController:addSoundSource("tch.ogg", "tch")
   spriteController:addTexture("spritesheet.png", "airplaine")
   spriteController:addQuadToTexture(
      "airplaine",
      "idle",
      0, 0,
      32, 32)
   local spriteComponent = spriteController:getSpriteComponentWithSprite(
      "airplaine",
      "idle"
   )

   rPrint(spriteComponent, nil, "spriteComponent")
   --soundController:playSound("tch")
   local x,y,w,h = spriteComponent.quad:getViewport()
   local positionOffsetComponent = componentFactory:createComponent(
      "PositionOffset",
      {
         x = -w / 2,
         y = -h / 2
      }
   )
   spriteSystem:addSpriteEntity(
      spriteComponent,
      entity1.positionComponent,
      positionOffsetComponent
   )
end

function love.draw()
	if debugMode then
		love.graphics.setColor(255, 0, 0, 255 * 0.8)
		love.graphics.print('Memory(kB): ' .. collectgarbage('count'), 5,5)
		love.graphics.print('FPS: ' .. love.timer.getFPS(), 5,25)
		love.graphics.print('Mouse: (' .. love.mouse.getX() .. ',' .. love.mouse.getY() .. ')', 85,25)
		love.graphics.setColor(255, 255, 255)
   end

   love.graphics.setColor(0, 255, 0, 255 * 0.8)
   love.graphics.circle(
      "fill",
      entity1.positionComponent.x, entity1.positionComponent.y,
      entity1.colliderComponent.radius,
      32)
   love.graphics.circle(
      "fill",
      entity2.positionComponent.x, entity2.positionComponent.y,
      entity2.colliderComponent.radius,
      32)

   love.graphics.setColor(255, 255, 255, 255)
   spriteSystem:draw()
end

local function update(dt)
   --print("frame: " .. frame .. "   dt: " .. dt)

   local y = 0
   local x = 0
   if inputSystem:isDown(1, "up") then
      y = y - 1
   end
   if inputSystem:isDown(1, "down") then
      y = y + 1
   end
   if inputSystem:isDown(1, "left") then
      x = x - 1
   end
   if inputSystem:isDown(1, "right") then
      x = x + 1
   end
   local speed = 100
   entity1.positionComponent.x = entity1.positionComponent.x + x * speed * dt
   entity1.positionComponent.y = entity1.positionComponent.y + y * speed * dt

   if inputSystem:isDown(1, "leftclick") then
      soundController:playSoundAttachedToPositionComponent(
         "tch",
         entity1.positionComponent
      )
   end

   collisionSystem:collideAllEntities()
   soundSystem:update()
end

function love.update(dt)
   local frameStartTime = love.timer.getTime()
   local newDT = dt + love.timer.getTime() - frameStartTime

   while newDT < SPEED_PER_FRAME do
   --   print(newDT, SPEED_PER_FRAME)
      newDT = dt + love.timer.getTime() - frameStartTime
   end

	if not paused then
      frame = frame + 1

      local remainingTime = newDT

      while remainingTime > 0 do
         if remainingTime > SPEED_PER_FRAME then
            update(SPEED_PER_FRAME)
            remainingTime = remainingTime - SPEED_PER_FRAME
         else
            update(remainingTime)
            remainingTime = 0
         end
      end
   end

	if debugMode and stableMemory then
		collectgarbage()
   end
   --print(love.timer.getFPS())
end

function love.focus(focused)
	if not debugMode then paused = not focused end
end

function love.keypressed(key)
	if key == '`' then
		debugMode = not debugMode
	end
	if key == '1' and debugMode then
		paused = not paused
	end
	if key == '2' and debugMode then
		stableMemory = not stableMemory
	end
end
