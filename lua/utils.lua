local M = {}

-- TODO: improve, we should stop shorting when we reach the screen size
M.format_filename = function(filepath)
  local path_parts = {}
  for part in string.gmatch(filepath, "([^/]+)") do
    table.insert(path_parts, part)
  end

  local screen_width = vim.api.nvim_win_get_width(0)
  local filename = path_parts[#path_parts]

  local formatted_path = filepath

  if #formatted_path > screen_width then
    local total_length = 0
    local shortened_parts = {}

    table.insert(shortened_parts, path_parts[1])
    total_length = total_length + #path_parts[1] + 1

    for i = 2, #path_parts - 1 do
      local part = path_parts[i]:sub(1, 1) -- Take the first letter
      table.insert(shortened_parts, part)
      total_length = total_length + #part + 1 -- Including slash

      if total_length + #filename + 1 <= screen_width then
        break
      end
    end

    table.insert(shortened_parts, filename)

    formatted_path = table.concat(shortened_parts, "/")
  end

  return formatted_path
end

return M
