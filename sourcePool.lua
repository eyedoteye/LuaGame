-- TODO: Move sourcePool closer to asset manager.
local sourcePool = {}

--- Creates a source pool. Holds multiple clones of the same source.
-- @param source [userdata]
function sourcePool.create(self, source)
  local pool = {
     original = source,
     sources = {},
     size = 0,
     largestSize = 0
  }
  return pool
end

--- Gets a Love2D source from the pool.
-- @return source [userdata]: Clone of original Love2D Source.
function sourcePool.get(self, pool)
   if pool.size == 0 then
      return pool.original:clone()
   end

   local source = pool.sources[pool.size]
   pool.size = pool.size - 1
   return source
end

--- Returns a sound source back into the pool. 
-- @param source [userdata]: Love2D Source to return to pool.
function sourcePool.returnSource(self, pool, source)
   pool.sources[pool.size + 1] = source
   pool.size = pool.size + 1
   if pool.size > pool.largestSize then
      pool.largestSize = pool.size
      print("Largest pool size: ".. pool.largestSize)
   end
end

return sourcePool