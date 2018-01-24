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



local playerPrototype = require "playerPrototype"
local mousePrototype = require "mousePrototype"
local enemySquadPrototype = require "enemySquadPrototype"

local playerHealthBarPrototype = require "playerHealthBarPrototype"

local player

function love.load()
   love.graphics.setBackgroundColor(130, 45, 165)

   spriteController:addTexture("player.png", "player")
   spriteController:addQuadToTexture(
      "player",
      "idle",
      0, 0,
      32, 32
   )
   spriteController:addQuadToTexture(
      "player",
      "invincible",
      0, 32,
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
   spriteController:addQuadToTexture(
      "player",
      "enemy",
      32, 32,
      32, 32
   )
   spriteController:addQuadToTexture(
      "player",
      "enemySpawner",
      64, 32,
      32, 32
   )
   spriteController:addQuadToTexture(
      "player",
      "healthBar",
      96, 0,
      94, 18
   )
   spriteController:addQuadToTexture(
      "player",
      "healthBarBlip",
      96, 18,
      10, 14
   )

   soundController:addSoundSource(
      "Fireball+1.wav",
      "Fireball"
   )

   collisionSystem:makeEntityTypesCollidable("Enemy","Enemy")
   collisionSystem:makeEntityTypeMovableByEntityType("Enemy", "Enemy")

   collisionSystem:makeEntityTypesCollidable("Enemy","Fireball")
   collisionSystem:makeEntityTypesCollidable("Player", "Enemy")
   collisionSystem:makeEntityTypeMovableByEntityType("Enemy", "Player")

   local screenWidth, screenHeight = love.graphics.getDimensions()
   player = playerPrototype:create(screenWidth / 2, screenHeight / 2)
   mousePrototype:create()

   playerHealthBarPrototype:create(player.healthComponent)
end

function love.draw()

   --
   love.graphics.setColor(255, 255, 255, 255)
   spriteSystem:draw()

   if debugMode then
		love.graphics.setColor(255, 0, 0, 255 * 0.8)
		love.graphics.print('Memory(kB): ' .. collectgarbage('count'), 5,5)
		love.graphics.print('FPS: ' .. love.timer.getFPS(), 5,25)
		love.graphics.print('Mouse: (' .. love.mouse.getX() .. ',' .. love.mouse.getY() .. ')', 85,25)
		love.graphics.setColor(255, 255, 255)
   end
end

local function update(dt)
   if inputController:isPressedThisFrame(1, "rightclick") then
      --enemyPrototype:create(love.mouse.getX(), love.mouse.getY(), player.positionComponent)
      enemySquadPrototype:create(love.mouse.getX(), love.mouse.getY(), 5)
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

local love_keypressed = love.keypressed
function love.keypressed(key)
   love_keypressed(key)
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