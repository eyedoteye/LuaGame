-- TODO: Move sourcePool closer to asset manager.
local sourcePoolFactory = {}

--- Gets a Love2D source from the pool.
-- @return source [userdata]: Clone of original Love2D Source.
local function sourcePool_get(self)
   if self.size == 0 then
      return self.original:clone()
   end

   local source = self.sources[self.size]
   self.size = self.size - 1
   return source
end

--- Returns a sound source back into the pool.
-- @param source [userdata]: Love2D Source to return to pool.
local function sourcePool_returnSource(self, source)
   self.sources[self.size + 1] = source
   self.size = self.size + 1
   if self.size > self.largestSize then
      self.largestSize = self.size
      print("Largest self size: ".. self.largestSize)
   end
end
--- Creates a source pool. Holds multiple clones of the same source.
-- @param source [userdata]: Love2D Source to instantiate the pool with.
function sourcePoolFactory.create(self, source)
  local pool = {
     original = source,
     sources = {},
     size = 0,
     largestSize = 0,

     get = sourcePool_get,
     returnSource = sourcePool_returnSource
  }
  return pool
end


return sourcePoolFactory