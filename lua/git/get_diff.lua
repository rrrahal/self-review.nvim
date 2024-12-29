local M = {}

M.get_diff = function(filename)
  local diff = vim.fn.system("git diff " .. filename)
  return vim.split(diff, "\n")
end

return M
