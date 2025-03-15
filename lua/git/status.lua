local M = {}

--- Parses a git status short-format line and extracts change type and staging status.
-- @param status_line string: A single line from `git status --short` output.
-- @return table: { change_type = "addition"|"deletion"|"rename"|"modification"|"unknown", staged = boolean, path = string } or nil, error message
function parse_line(line)
  local x, y, path = line:match("(.)(.)%s(.+)")

  if not x or not y then
    return nil, "Invalid status line"
  end

  local change_type
  if x == "A" or y == "A" then
    change_type = "addition"
  elseif x == "D" or y == "D" then
    change_type = "deletion"
  elseif x == "R" or y == "R" then
    change_type = "rename"
  elseif x == "M" or y == "M" or x == "T" or y == "T" then
    change_type = "modification"
  else
    change_type = "unknown"
  end

  local staged = x ~= " " and x ~= "?" and x ~= "!"

  return { change_type = change_type, staged = staged, path = path }
end

local parse_status_lines = function(lines)
  local files = {}

  for _, line in ipairs(lines) do
    local parsed = parse_line(line)
    table.insert(files, parsed)
  end

  return files
end

M.changed_files = function()
  local Job = require("plenary.job")
  local lines = {}
  Job:new({
    command = "git",
    args = { "status", "--porcelain", "-u", "--short" },
    on_exit = function(j)
      lines = j:result()
    end,
  }):sync()

  local parsed_files = parse_status_lines(lines)

  return parsed_files
end

-- (Internal) Exposed for testing purposes.
M._parse_line = parse_line

return M
