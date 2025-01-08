local M = {}

local parse_diff = function(diffArray)
  -- removes the header
  table.remove(diffArray, 1)
  table.remove(diffArray, 1)
  table.remove(diffArray, 1)
  table.remove(diffArray, 1)
  table.remove(diffArray, 1)
  return diffArray
end

M.get_diff = function(filename)
  local diff = vim.fn.system("git diff " .. filename)
  local diffArray = vim.split(diff, "\n")
  return parse_diff(diffArray)
end

return M
