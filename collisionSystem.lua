local entityMapFactory = require "entityMapFactory"
local clearTable = require "clearTable"



--- Collision Entity
-- (number: id) -- Automatically added by entityFactory
-- table: entityTypeComponent
-- table: positionComponent
-- table: colliderComponent

--- table: EntityTypeComponent
-- name: EntityType
-- string: type

--- table: PositionComponent
-- name: Position
-- number: x
-- number: y

--- table: ColliderComponent
-- Circle or CircleLine
--
--    table: Circle
--       name: Collider.Circle
--       float: radius
--
--    table: CircleLine
--       name: Collider.CircleLine
--       float: radius
--       float: length

local collisionSystem = {
   collidableMap = {}, -- table[string][string] bool: Maps collidable entity types.
   movableMap = {}, -- table[string][string] bool: Maps movable entity types to their respective mover entity types.

   entityMap = entityMapFactory:create() -- entityMap: Stores all collision entities.
}

--- Adds a collisionEntity to the collision system.
-- @param entityTypeComponent entityTypeComponent: Entity type of entity.
-- @param positionComponent positionComponent: Position of entity.
-- @param colliderComponent colliderComponent: Collider of entity.
-- @return number: This system's ID of the collisionEntity.
function collisionSystem.addCollisionEntity(
   self,
   entityTypeComponent,
   positionComponent,
   colliderComponent
)
   local id = self.entityMap:createAndAddEntity({
      entityTypeComponent = entityTypeComponent,
      positionComponent = positionComponent,
      colliderComponent = colliderComponent,
   })

   return id
end

--- Removes a collisionEntity from the collision system.
-- @param id string: This system's ID of the entity to remove.
function collisionSystem.removeCollisionEntity(self, id)
   self.entityMap:remove(id)
end

--- Turns on collision checking between two entity types.
-- @param firstEntityType entityTypeComponent: Type name of the first entity to make collidable.
-- @param secondEntityType entityTypeComponent: Type name of the second entity to make collidable.
function collisionSystem.makeEntitiesCollidable(self, firstEntityType, secondEntityType)
   self.collidableMap[firstEntityType] = self.collidableMap[firstEntityType] or {}
   self.collidableMap[secondEntityType] = self.collidableMap[secondEntityType] or {}
   self.collidableMap[firstEntityType][secondEntityType] = true
   self.collidableMap[secondEntityType][firstEntityType] = true
end

--- Turns off collision checking between two entity types.
-- @param firstEntityType entityTypeComponent: Type name of the first entity to make uncollidable.
-- @param secondEntityType entityTypeComponent: Type name of the second entity to make uncollidable.
function collisionSystem.unmakeEntitiesCollidable(self, firstEntityType, secondEntityType)
   self.collidableMap[firstEntityType][secondEntityType] = nil
   self.collidableMap[secondEntityType][firstEntityType] = nil
end

--- Returns if two entity types are collidable.
-- @param firstEntityType entityTypeComponent: Type name of first entity.
-- @param secondEntityType entityTypeComponent: Type name of the second entity.
-- @return bool: Return true if firstEntityType and secondEntityType are collidable.
function collisionSystem.areEntitiesCollidable(self, firstEntityType, secondEntityType)
   if self.collidableMap[firstEntityType] == nil then
      return false
   end
   return self.collidableMap[firstEntityType][secondEntityType]
end

--- Turns on one-way movability between two entity types.
-- @param firstEntityType entityTypeComponent: Type name of entity that will be made the movable.
-- @param secondEntityType entityTypeComponent: Type name of entity that will be made the mover.
function collisionSystem.makeEntityMovableByEntity(self, firstEntityType, secondEntityType)
   self.movableMap[firstEntityType] = self.movableMap[firstEntityType] or {}
   self.movableMap[firstEntityType][secondEntityType] = true
end

--- Turns off one-way movability between two entity types.
-- @param firstEntityType entityTypeComponent: Entity type that will no longer be the movable.
-- @param secondEntityType entityTypeComponent: Entity type that will no longer be the mover.
function collisionSystem.unmakeEntityMovableByEntity(self, firstEntityType, secondEntityType)
   self.movableMap[firstEntityType][secondEntityType] = nil
end

--- Returns if first entity type is movable by second entity type.
-- @param firstEntityType entityTypeComponent: Entity type to be checked for being the movable.
-- @param secondEntityType entityTypeComponent: Entity type to be checked for being the mover.
function collisionSystem.isEntityMovableByEntity(self, firstEntityType, secondEntityType)
   if self.movableMap[firstEntityType] == nil then
      return false
   end
   return self.movableMap[firstEntityType][secondEntityType]
end


local function clearCollisionData(collisionData)
   clearTable(collisionData.firstToSecondDirection)
   clearTable(collisionData.secondToFirstDirection)
   clearTable(collisionData)
end
--- Checks if two circles are colliding.
-- @param x1 number: Position of the first circle along the x-axis.
-- @param y1 number: Position of the first circle along the y-axis.
-- @param r1 number: Radius of the first circle.
-- @param x2 number: Position of the second circle along the x-axis.
-- @param y2 number: Position of the second circle along the y-axis.
-- @param r2 number: Radius of the second circle.
-- @return bool: True if the two entities are colliding.
-- @return collisionData: Holds collision information between entities.
--    table: collisionData
--       bool: isColliding
--       table: firstToSecondDirection
--          float: x
--          float: y
--       table: secondToFirstDirection
--          float: x
--          float: y
--       float: distanceBetweenCenters
--       float: displacementDistance
local function areCirclesColliding(
   x1, y1, r1,
   x2, y2, r2
)
	local offsetX = x2 - x1
	local offsetY = y2 - y1
   local distance = math.sqrt(offsetX * offsetX + offsetY * offsetY)

   local totalRadius = r1 + r2

   local isColliding = false
   if distance <= totalRadius then
      isColliding = true
   end

   local collisionData = {
      isColliding = isColliding,
      firstToSecondDirection = {
         x = -offsetX / distance,
         y = -offsetY / distance
      },
      secondToFirstDirection = {
         x = offsetX / distance,
         y = offsetY / distance
      },
      distanceBetweenCenters = distance,
      displacementDistance = totalRadius - distance,
   }

	return isColliding, collisionData
end

-- TODO: Port this from tlz
--- Collides two entities and resolves any needed position displacements.
-- @param firstEntity collisionEntity: First collisionEntity.
-- @param secondEntity collisionEntity: Second collisionEntity.
-- @return bool: True if the two entities are colliding.
-- @return collisionData: Holds collision information between entities.
--    table: collisionData
--       bool: isColliding
--       table: firstToSecondDirection
--          float: x
--          float: y
--       table: secondToFirstDirection
--          float: x
--          float: y
--       float: distanceBetweenCenters
--       float: displacementDistance
local function collideEntities(firstEntity, secondEntity)
   if firstEntity.colliderComponent.name == "Collider.Circle" then
      if secondEntity.colliderComponent.name == "Collider.Circle" then
         local isColliding, collisionData = areCirclesColliding(
            firstEntity.positionComponent.x, firstEntity.positionComponent.y, firstEntity.colliderComponent.radius,
            secondEntity.positionComponent.x, secondEntity.positionComponent.y, secondEntity.colliderComponent.radius
         )

         if isColliding then
            if collisionSystem:isEntityMovableByEntity(
               secondEntity.entityTypeComponent,
               firstEntity.entityTypeComponent
            ) then

               if collisionSystem:isEntityMovableByEntity(
                  firstEntity.entityTypeComponent,
                  secondEntity.entityTypeComponent
               ) then
                  collisionData.displacementDistance = collisionData.displacementDistance / 2

                  firstEntity.positionComponent.x = firstEntity.positionComponent.x +
                     collisionData.firstToSecondDirection.x * collisionData.displacementDistance
                  firstEntity.positionComponent.y = firstEntity.positionComponent.y +
                     collisionData.firstToSecondDirection.y * collisionData.displacementDistance
               end

               secondEntity.positionComponent.x = secondEntity.positionComponent.x +
                  collisionData.secondToFirstDirection.x * collisionData.displacementDistance
               secondEntity.positionComponent.y = secondEntity.positionComponent.y +
                  collisionData.secondToFirstDirection.y * collisionData.displacementDistance

            elseif collisionSystem:isEntityMovableByEntity(
               firstEntity.entityTypeComponent,
               secondEntity.entityTypeComponent
            ) then
               firstEntity.positionComponent.x = firstEntity.positionComponent.x +
                  collisionData.firstToSecondDirection.x * collisionData.firstDisplacementDistance
               firstEntity.positionComponent.y = firstEntity.positionComponent.y +
                  collisionData.firstToSecondDirection.y * collisionData.firstDisplacementDistance
            end
         end

         return isColliding, collisionData

      elseif secondEntity.colliderComponent.name == "Collider.CircleLine" then
         print("collideEntities: Collider.Circle + Collider.CircleLine not implemented")
      end
   elseif firstEntity.colliderComponent.name == "Collider.CircleLine" then
      if secondEntity.colliderComponent.name == "Collider.Circle" then
         print("collideEntities: Collider.CircleLine + Collider.Circle not implemented")
      elseif secondEntity.colliderComponent.name == "Collider.CircleLine" then
         print("collideEntities: Collider.CircleLine + Collider.CircleLine not implemented")
      end
   end
end

--- Collides all collisionEntitys with each other and resolves their collisions.
local function collideAllEntities(self)
	local collisions = {}

   local size = self.entityMap:getSize()
   local entities = self.entityMap:getList()
	local i = 1
	while i <= size do
		local ii = i + 1
		while ii <= size do
			local collisionEntity1 = entities[i]
			local collisionEntity2 = entities[ii]

         --print("i = .. " .. i .. "   ii = " .. ii)
--         if collisionEntity1 == nil then
--            print("collisionEntity1 == nil   i = " .. i .. "   ii = " .. ii)
--         end
--         if collisionEntity2 == nil then
--            print("collisionEntity2 == nil   i = " .. i .. "   ii = " .. ii)
--         end
         local isColliding, collisionData = collideEntities(collisionEntity1, collisionEntity2)

         if isColliding then
            table.insert(collisions, {collisionEntity1, collisionEntity2, collisionData})
         else
            clearCollisionData(collisionData)
         end

			ii = ii + 1
		end
		i = i + 1
	end


   for _, collisionPair in ipairs(collisions) do
	--	collisionPair[1]:onCollision(collisionPair[2], collisionPair[3])
	--	collisionPair[3].firstToSecondDirection.x = -collisionPair[3].firstToSecondDirection.x
	--	collisionPair[3].firstToSecondDirection.y = -collisionPair[3].firstToSecondDirection.y
   --	collisionPair[2]:onCollision(collisionPair[1], collisionPair[3])
      clearCollisionData(collisionPair[3])
   end
end

--- Performs updates needed for mainting collision system.
-- Collides all collisionEntitys with each other and resolves their collisions.
function collisionSystem.update(self)
   collideAllEntities(self)
end

return collisionSystem