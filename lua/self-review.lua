local status = require("git.status")
local windows = require("windows")
local diffMod = require("git.diff")

-- TODO: add meta information about the file (filename) and the amount of diffs
-- TODO: add footer with keymaps/actions
-- TODO: add keymap to add diff

local M = {}

-- Define custom highlight groups similar to VSCode diff colors
vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#81C784", bg = "none" })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#E57373", bg = "none" })
vim.api.nvim_set_hl(0, "DiffChange", { fg = "#64B5F6", bg = "none" })

local ns_gutter = vim.api.nvim_create_namespace("diff_gutter")

local function apply_diff_highlights(buf, lines)
  for i, line in ipairs(lines) do
    if line:match("^%+") then
      vim.api.nvim_buf_add_highlight(buf, -1, "DiffAdd", i - 1, 0, -1)
    elseif line:match("^%-") then
      vim.api.nvim_buf_add_highlight(buf, -1, "DiffDelete", i - 1, 0, -1)
    end
  end
end

local function add_gutter_marks(buf, lines)
  vim.api.nvim_buf_clear_namespace(buf, ns_gutter, 0, -1)
  for i, line in ipairs(lines) do
    if line:match("^%+") then
      vim.api.nvim_buf_set_extmark(buf, ns_gutter, i - 1, 0, {
        virt_text = { { "▎", "DiffAdd" } },
        virt_text_pos = "overlay",
      })
    elseif line:match("^%-") then
      vim.api.nvim_buf_set_extmark(buf, ns_gutter, i - 1, 0, {
        virt_text = { { "▎", "DiffDelete" } },
        virt_text_pos = "overlay",
      })
    end
  end
end

local set_window_content = function(f_windows, header, body, footer)
  vim.api.nvim_buf_set_lines(f_windows.body.buf, 0, -1, false, body)
  f_windows.set_file_header(header)
  f_windows.set_footer(footer)

  -- TODO: refactor this to remove it from here
  apply_diff_highlights(f_windows.body.buf, body)
  add_gutter_marks(f_windows.body.buf, body)

  local ft = vim.filetype.match({ filename = header }) or "plaintext"
  vim.bo[f_windows.body.buf].filetype = ft
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
end

return M
