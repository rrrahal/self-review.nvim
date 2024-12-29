local M = {}
local gitFns = require("git")
local windows = require("window")
local gitDiff = require("git.get_diff")

M.setup = function() end

local files = gitFns.get_git_files()

for _, file in ipairs(files) do
  if _ == 1 then
    local diff = gitDiff.get_diff(file)
    local w = windows.create_window()
    local lines = vim.split(diff, "\n")
    vim.api.nvim_buf_set_lines(w.buf, 1, -1, false, lines)
  end
end

return M
