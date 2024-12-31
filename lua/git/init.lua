local M = {}

local trim = function(s)
  return vim.trim(s)
end

-- TODO: refactor this module
M.get_git_files = function()
  -- TODO: does not work when adding a new folder
  local lines = vim.fn.system("git status -s")

  local files = {}

  for line in lines:gmatch("[^\r\n]+") do
    local line_without_spaces = trim(line)
    local value = line_without_spaces:match("^%S+%s+(.*)$") or ""
    table.insert(files, value)
  end

  return files
end

return M
