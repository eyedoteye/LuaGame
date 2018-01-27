local pointTools = {}

function pointTools:getDistanceFromPointToPoint(
   x1, y1,
   x2, y2
)
   local xOffset = x2 - x1
   local yOffset = y2 - y1

   return math.sqrt(xOffset * xOffset + yOffset * yOffset)
end

return pointTools