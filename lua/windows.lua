local M = {}

local windows_configs = function()
  local width = vim.o.columns
  local height = vim.o.lines

  local win_width = math.floor(width * 0.8)
  local win_height = math.floor(height * 0.8)

  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  return {
    header = {
      relative = "editor",
      width = win_width - 2, -- accounting for the border padding
      height = 1,
      row = row - 2,
      col = col,
      style = "minimal",
      border = "rounded",
      focusable = false,
    },

    body = {
      relative = "editor",
      width = win_width - 2,
      height = win_height - 2 - 2,
      row = row + 1,
      col = col,
      style = "minimal",
      border = "rounded",
    },
    footer = {
      relative = "editor",
      width = win_width - 2, -- accounting for the border padding
      height = 1,
      row = row + win_height - 1,
      col = col,
      style = "minimal",
      border = "rounded",
      focusable = false,
    },
  }
end

local create_window = function(config)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, config)

  return { win = win, buf = buf }
end

M.create_windows = function()
  local cfgs = windows_configs()

  local header = create_window(cfgs.header)
  local footer = create_window(cfgs.footer)
  local body = create_window(cfgs.body)

  -- TODO: refactor this - separate windows from style

  vim.api.nvim_set_hl(0, "GitDiffFilename", { fg = "#06B6D4", bold = true })
  vim.api.nvim_set_hl(0, "GitDiffFooter", { fg = "#06B6D4", bold = true })

  local function update_header(buf, filename)
    local centered_title = " " .. filename .. " "
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { centered_title })
    vim.api.nvim_buf_add_highlight(buf, -1, "GitDiffFilename", 0, 1, -1)
  end

  local function update_footer(buf, content)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_add_highlight(buf, -1, "GitDiffFooter", 0, 1, -1)
  end

  local function set_file_header(filename)
    update_header(header.buf, filename)
  end

  local function set_footer(content)
    update_footer(footer.buf, content)
  end

  -- Cleanup windows when body is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = body.buf,
    callback = function()
      pcall(vim.api.nvim_win_close, header.win, true)
      pcall(vim.api.nvim_win_close, footer.win, true)
    end,
  })

  return { header = header, body = body, footer = footer, set_file_header = set_file_header, set_footer = set_footer }
end

return M
