local M = {}

-- given a raw diff, returns a nice structure with the diff
-- {
--  original: string[]
--  header: {
--    raw_header: string[]
--  },
--  hunks: Hunk[],
--  parsed: string[]
-- }
-- TODO: REDO this with treesitter
local parse_diff = function(diffArray)
  local diffStruct = {
    original = diffArray,
    header = { raw_header = {} },
    hunks = {},
    parsed = {},
  }

  local in_header = true
  local current_hunk = nil

  for _, line in ipairs(diffArray) do
    if in_header then
      table.insert(diffStruct.header.raw_header, line)
      if vim.startswith(line, "@@") then
        current_hunk = { start_line = line, content = {} }
        in_header = false
        table.insert(diffStruct.hunks, current_hunk)
      end
    elseif vim.startswith(line, "@@") then
      -- New hunk starts
      current_hunk = { start_line = line, content = {} }
      table.insert(diffStruct.hunks, current_hunk)
    else
      table.insert(diffStruct.parsed, line)
    end
  end
  return diffStruct
end

M.get_diff = function(file)
  local filename = file.path
  local type = file.type
  if type == "M" then
    local diff = vim.fn.system("git diff HEAD " .. filename)
    local diffArray = vim.split(diff, "\n")
    return parse_diff(diffArray)
  end

  if type == "A" then
    local diff = vim.fn.system("git diff --no-index /dev/null " .. filename)
    local diffArray = vim.split(diff, "\n")
    return parse_diff(diffArray)
  end

  -- TODO: delete is still not working properly
  if type == "D" then
    local diff = vim.fn.system("git diff --no-index " .. filename .. " /dev/null")
    local diffArray = vim.split(diff, "\n")
    return parse_diff(diffArray)
  end
end

return M
