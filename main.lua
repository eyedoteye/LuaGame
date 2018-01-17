local debugMode = false
local stableMemory = true
local paused = false
local SPEED_PER_FRAME = 1 / 60
local frame = 0



local inputController = require "inputController"
local collisionSystem = require "collisionSystem"
local soundSystem = require "soundSystem"
local soundController = require "soundController"
local spriteSystem = require "spriteSystem"
local spriteController = require "spriteController"
local updateSystem = require "updateSystem"

local componentFactory = require "componentFactory"
local entityFactory = require "entityFactory"



local player = require "player"
local mouse = require "mouse"


function love.load()
   spriteController:addTexture("player.png", "player")
   spriteController:addQuadToTexture(
      "player",
      "idle",
      0, 0,
      32, 32
   )
   spriteController:addQuadToTexture(
      "player",
      "crosshair",
      32, 0,
      32, 32
   )
   spriteController:addQuadToTexture(
      "player",
      "fireball",
      64, 0,
      32, 32
   )
   player:load()
   mouse:load()
end

function love.draw()
	if debugMode then
		love.graphics.setColor(255, 0, 0, 255 * 0.8)
		love.graphics.print('Memory(kB): ' .. collectgarbage('count'), 5,5)
		love.graphics.print('FPS: ' .. love.timer.getFPS(), 5,25)
		love.graphics.print('Mouse: (' .. love.mouse.getX() .. ',' .. love.mouse.getY() .. ')', 85,25)
		love.graphics.setColor(255, 255, 255)
   end
   --
   love.graphics.setColor(255, 255, 255)
   love.graphics.circle(
      "fill",
      player.positionComponent.x,
      player.positionComponent.y,
      16
   )

   --
   love.graphics.setColor(255, 255, 255, 255)
   spriteSystem:draw()
end

local function update(dt)
   if inputController:isPressedThisFrame(1, "leftclick") then
      print("leftclick")
   end
   if inputController:isPressedThisFrame(1, "up") then
      print("up")
   end
   if inputController:isReleasedThisFrame(1, "leftclick") then
      print("leftclick released")
   end
   if inputController:isReleasedThisFrame(1, "up") then
      print("up released")
   end
   --
   updateSystem:update(dt)
   collisionSystem:update()
   soundSystem:update()
   inputController:frameEndUpdate()
end

function love.update(dt)
   local frameStartTime = love.timer.getTime()
   local newDT = dt + love.timer.getTime() - frameStartTime

   while newDT < SPEED_PER_FRAME do
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
end

function love.focus(focused)
	if not debugMode then paused = not focused end
end

--[[function love.keypressed(key)
	if key == '`' then
		debugMode = not debugMode
	end
	if key == '1' and debugMode then
		paused = not paused
	end
	if key == '2' and debugMode then
		stableMemory = not stableMemory
	end
end]]--