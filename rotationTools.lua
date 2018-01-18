local rotationTools = {}

function rotationTools:getRotationFromPointToPoint(
   x1, y1,
   x2, y2
)
   local xOffset = x2 - x1
   local yOffset = y2 - y1
   return math.atan2(xOffset, -yOffset) / math.pi * 180
end

return rotationTools