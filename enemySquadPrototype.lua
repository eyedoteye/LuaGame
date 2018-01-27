local updateSystem = require "updateSystem"
local spriteSystem = require "spriteSystem"
local spriteController = require "spriteController"

local entityFactory = require "entityFactory"
local componentFactory = require "componentFactory"
local rotationTools = require "rotationTools"

local enemyPrototype = require "enemyPrototype"


local enemySquadPrototype = {}

local distanceBetweenEnemies = 32 + 4

local function getDistanceFromPointToPoint(
   x1, y1,
   x2, y2
)
   local xOffset = x2 - x1
   local yOffset = y2 - y1
   local distance = math.sqrt(xOffset * xOffset + yOffset * yOffset)

   return distance
end

local function delete(self)
   spriteSystem:removeEntity(self.id)
   updateSystem:removeEntity(self.id)
end

local function update(self, dt)
   if #self.enemies < self.totalEnemyCount then
      if #self.enemies >= 1 then
         local lastEnemy = self.enemies[#self.enemies]
         local distance = getDistanceFromPointToPoint(
            lastEnemy.positionComponent.x, lastEnemy.positionComponent.y,
            self.positionComponent.x, self.positionComponent.y
         )
         if distance >= distanceBetweenEnemies then
            local dirFromLastEnemy = rotationTools:getRotationFromPointToPoint(
              lastEnemy.positionComponent.x, lastEnemy.positionComponent.y,
              self.positionComponent.x, self.positionComponent.y
            )
            local xDir, yDir = rotationTools:getVectorFromRotation(dirFromLastEnemy)
            local x = lastEnemy.positionComponent.x - xDir * distanceBetweenEnemies
            local y = lastEnemy.positionComponent.y - yDir * distanceBetweenEnemies

            table.insert(
               self.enemies,
               enemyPrototype:create(
                  x, y,
                  self.playerPositionComponent
               )
            )
         end
      else
         table.insert(
            self.enemies,
            enemyPrototype:create(
               self.positionComponent.x, self.positionComponent.y,
               self.playerPositionComponent
            )
         )
      end
   else
      local allMembersDestroyed = true 
      for _, enemy in ipairs(self.enemies) do
         allMembersDestroyed = allMembersDestroyed and enemy.deleted 
      end
      if allMembersDestroyed then
         delete(self)
      end
   end
end

function enemySquadPrototype.create(
   self,
   x, y,
   enemyPaths
)
   local squad = entityFactory:createEntity({
      positionComponent = componentFactory:createComponent(
         "Position",
         {
            x = x,
            y = y
         }
      ),
      updateComponent = componentFactory:createComponent(
         "Update",
         {
            update = update
         }
      ),
      spriteComponent = spriteController:getSpriteComponentWithSprite(
         "player",
         "enemySpawner"
      )
   })

   updateSystem:addEntity(squad)
   spriteSystem:addEntity(squad)

   squad.totalEnemyCount = #enemyPaths
   squad.enemies = {}

   return squad
end

return enemySquadPrototype