local M = {}

M.get_diff = function(filename)
  local diff = vim.fn.system("git diff " .. filename)
  return diff
end

return M
