local componentFactory = require "componentFactory"



--- list: textureToQuadsMap
-- map: (textureName)
--    userdata [Image]: texture
--    map: quads
--       userdata(s) [Quad]: (quadName)
local spriteController = {
   textureToQuadsMap = {},
}


--- Temporary way to add textures until asset manager is added.
-- @param textureFilePath string: Relative path to sound file.
-- @param textureName string: Desired name for texture.
function spriteController.addTexture(self, textureFilePath, textureName)
   if self.textureToQuadsMap[textureName] ~= nil then
      error("spriteController.addTexture: textureName already exists in map.")
   end

   local texture = love.graphics.newImage(textureFilePath)
   self.textureToQuadsMap[textureName] = {
      texture = texture,
      quads = {}
   }
end

--- Temporary way to add quads to texture until asset manager is added.
-- Adding a quad to a texture allows for a subimage within the texture to be used for display.
-- @param textureName string: Name of texture to add quad to.
-- @param quadName string: Desired name of quad.
-- @param x integer: Position of quad in texture along the x-axis.
-- @param y integer: Position of quad in texture along the y-axis.
-- @param width integer: Width of the quad.
-- @param height integer: Height of the quad.
function spriteController.addQuadToTexture(
   self,
   textureName,
   quadName,
   x, y,
   width, height
)
   local textureToQuadMap = self.textureToQuadsMap[textureName]
   if textureToQuadMap == nil then
      error("spriteController.addQuadToTexture: textureName does not exist in map.")
   end
   if textureToQuadMap.quads[quadName] ~= nil then
      error("spriteController.addQuadToTexture: quadName already exists in map.")
   end

   local texture = textureToQuadMap.texture
   -- Intentional mutation of non-standard global variable 'love'
   -- Implementation of love2d v0.10.2 api:
   --    https://love2d.org/w/index.php?title=love.graphics.newQuad&oldid=18877
   local quad = love.graphics.newQuad(
      x, y,
      width, height,
      texture:getWidth(), texture:getHeight()
   )
   textureToQuadMap.quads[quadName] = quad
end

--- Creates and returns a new spriteComponent with the desired sprite.
-- @param textureName string: Name of texture that the sprite is from.
-- @param quadName string: Name of quad that that the sprite is from.
-- @return spriteComponent: spriteComponent with the desired sprite.
function spriteController.getSpriteComponentWithSprite(
   self,
   textureName,
   quadName
)
   local spriteComponent = componentFactory:createComponent("Sprite", {})

   self:updateSpriteComponentWithSprite(spriteComponent, textureName, quadName)

   return spriteComponent
end

--- Updates an existing spriteComponent with the desired sprite.
-- @param spriteComponent spriteComponent: The spriteComponent to update.
-- @param textureName string: Name of texture that the sprite is from.
-- @param quadName string: Name of quad that that the sprite is from.
function spriteController.updateSpriteComponentWithSprite(
   self,
   spriteComponent,
   textureName,
   quadName
)
   local textureToQuadMap = self.textureToQuadsMap[textureName]
   spriteComponent.textureName = textureName
   spriteComponent.quadName = quadName
   spriteComponent.texture = textureToQuadMap.texture
   spriteComponent.quad = textureToQuadMap.quads[quadName]
end

return spriteController