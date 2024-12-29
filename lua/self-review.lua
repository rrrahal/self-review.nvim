local M = {}
local gitFns = require("git")
local windows = require("window")
local gitDiff = require("git.get_diff")

-- TODO: add meta information about the file (filename) and the amount of diffs
-- TODO: add footer with keymaps/actions
-- TODO: add keymap to add diff

M.setup = function() end

M.start_diff = function()
  local files = gitFns.get_git_files()
  local w = windows.create_window()
  vim.bo[w.buf].filetype = "diff"

  local current_diff = 1
  local diff = gitDiff.get_diff(files[current_diff])
  vim.api.nvim_buf_set_lines(w.buf, 0, -1, false, diff)

  vim.keymap.set("n", "n", function()
    current_diff = math.min(current_diff + 1, #files)
    local newDiff = gitDiff.get_diff(files[current_diff])
    vim.api.nvim_buf_set_lines(w.buf, 0, -1, false, newDiff)
  end, {
    buffer = w.buf,
  })

  vim.keymap.set("n", "p", function()
    current_diff = math.max(current_diff - 1, 1)
    local newDiff = gitDiff.get_diff(files[current_diff])
    vim.api.nvim_buf_set_lines(w.buf, 0, -1, false, newDiff)
  end, {
    buffer = w.buf,
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(w.win, true)
  end, {
    buffer = w.buf,
  })
end

return M
