local function clearTable(table)
   for key in pairs(table) do
      table[key] = nil
   end
end

return clearTable