local componentFactory = require "componentFactory"



local spriteController = {
   textureToQuadsMap = {},
}

--- list: textureToQuadsMap
-- map: (textureName)
--    userdata [Image]: texture
--    map: quads
--       userdata(s) [Quad]: (quadName)

-- TODO: Connect with asset manager.
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
   local quad = love.graphics.newQuad(
      x, y,
      width, height,
      texture:getWidth(), texture:getHeight()
   )
   textureToQuadMap.quads[quadName] = quad
end

function spriteController.getSpriteComponentWithSprite(
   self,
   textureName,
   quadName
)
   local spriteComponent = componentFactory:createComponent("Sprite", {})

   self:updateSpriteComponentWithSprite(spriteComponent, textureName, quadName)

   return spriteComponent
end

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