local status = require("git.status")
local windows = require("windows")
local diffMod = require("git.diff")

-- TODO: add keymap to add diff

local M = {}

local set_window_content = function(f_windows, header, body, footer)
  f_windows.set_header(header)
  f_windows.set_footer(footer)
  f_windows.set_body(body)
end

-- TODO: is it safe to add those keymaps? double check
M.start_diff = function()
  local files = status.changed_files()

  -- if there are no changed files, then do nothing
  if #files == 0 then
    vim.print("No changed files found in current repo")
    return
  end
  local floating_windows = windows.create_windows()

  local current_diff = 1
  local diff = diffMod.get_diff(files[current_diff])
  set_window_content(floating_windows, files[current_diff].path, diff.parsed, { current_diff .. "/" .. #files })

  vim.keymap.set("n", "n", function()
    current_diff = math.min(current_diff + 1, #files)
    local newDiff = diffMod.get_diff(files[current_diff])
    set_window_content(floating_windows, files[current_diff].path, newDiff.parsed, { current_diff .. "/" .. #files })
  end, {
    buffer = floating_windows.body.buf,
  })

  vim.keymap.set("n", "p", function()
    current_diff = math.max(current_diff - 1, 1)
    local newDiff = diffMod.get_diff(files[current_diff])
    set_window_content(floating_windows, files[current_diff].path, newDiff.parsed, { current_diff .. "/" .. #files })
  end, {
    buffer = floating_windows.body.buf,
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(floating_windows.body.win, true)
  end, {
    buffer = floating_windows.body.buf,
  })

  vim.keymap.set("n", "g", function()
    local filepath = files[current_diff].path

    -- Get the list of all windows
    local ws = vim.api.nvim_list_wins()

    -- Find the first non-floating window
    local target_win = nil
    for _, win in ipairs(ws) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative == "" then -- Not a floating window
        target_win = win
        break
      end
    end

    if not target_win then
      print("No non-floating window found")
      return
    end

    vim.api.nvim_set_current_win(target_win)

    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    vim.api.nvim_win_close(floating_windows.body.win, true)
  end, {
    buffer = floating_windows.body.buf,
  })
end

return M
