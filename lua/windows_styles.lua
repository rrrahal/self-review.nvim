local M = {}

-- HEADER
vim.api.nvim_set_hl(0, "GitDiffFilename", { fg = "#06B6D4", bold = true })

M.apply_header_styles = function(buf)
  vim.api.nvim_buf_add_highlight(buf, -1, "GitDiffFilename", 0, 1, -1)
end

-- FOOTER
vim.api.nvim_set_hl(0, "GitDiffFooter", { fg = "#06B6D4", bold = true })

M.apply_footer_styles = function(buf)
  vim.api.nvim_buf_add_highlight(buf, -1, "GitDiffFooter", 0, 1, -1)
end

-- BODY
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

M.apply_body_styles = function(buf, content)
  apply_diff_highlights(buf, content)
  add_gutter_marks(buf, content)
end

return M
