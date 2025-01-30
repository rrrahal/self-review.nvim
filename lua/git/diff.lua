local M = {}

-- given a raw diff, returns a nice structure with the diff
-- {
--  original: string[]
--  header: {
--    raw_header: string[]
--  },
--  chunks: Chunk[],
--  parsed: string[]
-- }
local parse_diff = function(diffArray)
  local diffStruct = {
    original = diffArray,
    header = { raw_header = {} },
    chunks = {},
    parsed = {},
  }

  local in_header = true
  local current_chunk = nil

  for _, line in ipairs(diffArray) do
    if in_header then
      table.insert(diffStruct.header.raw_header, line)
      if vim.startswith(line, "@@") then
        current_chunk = { start_line = line, content = {} }
        in_header = false
        table.insert(diffStruct.chunks, current_chunk)
      end
    elseif vim.startswith(line, "@@") then
      -- New chunk starts
      current_chunk = { start_line = line, content = {} }
      table.insert(diffStruct.chunks, current_chunk)
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

  if type == "D" then
    local diff = vim.fn.system("git diff --no-index " .. filename .. " /dev/null")
    local diffArray = vim.split(diff, "\n")
    return parse_diff(diffArray)
  end
end

return M
