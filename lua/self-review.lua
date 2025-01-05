local status = require("git.status")
local windows = require("windows")
local diffMod = require("git.diff")

-- TODO: add meta information about the file (filename) and the amount of diffs
-- TODO: add footer with keymaps/actions
-- TODO: add keymap to add diff

local M = {}

local set_window_content = function(f_windows, header, body, footer)
  vim.api.nvim_buf_set_lines(f_windows.body.buf, 0, -1, false, body)
  vim.api.nvim_buf_set_lines(f_windows.header.buf, 0, -1, false, header)
  vim.api.nvim_buf_set_lines(f_windows.footer.buf, 0, -1, false, footer)
end

-- TODO: it breaks when there are no diffs
-- TODO: is it safe to add those keymaps? double check
M.start_diff = function()
  local files = status.changed_files()

  -- if there are no changed files, then do nothing
  if #files == 0 then
    vim.print("No changed files found in current repo")
    return
  end
  local floating_windows = windows.create_windows()
  vim.bo[floating_windows.body.buf].filetype = "diff"

  local current_diff = 1
  local diff = diffMod.get_diff(files[current_diff].path)
  set_window_content(floating_windows, { files[current_diff].path }, diff, { current_diff .. "/" .. #files })

  vim.keymap.set("n", "n", function()
    current_diff = math.min(current_diff + 1, #files)
    local newDiff = diffMod.get_diff(files[current_diff].path)
    set_window_content(floating_windows, { files[current_diff].path }, newDiff, { current_diff .. "/" .. #files })
  end, {
    buffer = floating_windows.body.buf,
  })

  vim.keymap.set("n", "p", function()
    current_diff = math.max(current_diff - 1, 1)
    local newDiff = diffMod.get_diff(files[current_diff].path)
    set_window_content(floating_windows, { files[current_diff].path }, newDiff, { current_diff .. "/" .. #files })
  end, {
    buffer = floating_windows.body.buf,
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(floating_windows.body.win, true)
  end, {
    buffer = floating_windows.body.buf,
  })
end

return M
