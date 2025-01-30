local M = {}

-- TODO: add docs for LSP/Intelisense
local parse_status_lines = function(lines)
  local files = {}

  for _, line in ipairs(lines) do
    local trimmed_line = vim.trim(line)
    local type, path = trimmed_line:match("^(%S+)[ ]*(.*)$")
    if type == "R" then
      local split = vim.split(path, " -> ", { plain = true })
      local old_path = split[1]
      local new_path = split[2]
      local parsed = { type = type, path = old_path, new_path = new_path }
      table.insert(files, parsed)
    elseif type == "??" then
      local parsed = { type = "A", path = path }
      table.insert(files, parsed)
    else
      local parsed = { type = type, path = path }
      table.insert(files, parsed)
    end
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

  local parsed_files = parse_status_lines(lines)

  return parsed_files
end

-- (Internal) Exposed for testing purposes.
M._parse_status_lines = parse_status_lines

return M
