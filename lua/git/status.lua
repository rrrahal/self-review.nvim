local M = {}

local trim = function(s)
  return vim.trim(s)
end

-- TODO: add tests for this function
local parse_files = function(lines)
  local files = {}

  for _, line in ipairs(lines) do
    local trimmed_line = trim(line)
    local type, path = trimmed_line:match("^(%S+)[ ]*(.*)$")
    local parsed = { type = type, path = path }
    table.insert(files, parsed)
  end

  return files
end

M.changed_files = function()
  local Job = require("plenary.job")
  local lines = {}
  Job:new({
    command = "git",
    args = { "status", "--porcelain", "-u" },
    on_exit = function(j)
      lines = j:result()
    end,
  }):sync()

  local parsed_files = parse_files(lines)

  return parsed_files
end

return M
