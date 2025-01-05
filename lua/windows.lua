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
      width = win_width,
      height = 1,
      row = row,
      col = col,
      style = "minimal",
    },

    body = {
      relative = "editor",
      width = win_width,
      height = win_height - 1,
      row = row + 1,
      col = col,
      style = "minimal",
    },
    footer = {
      relative = "editor",
      width = win_width,
      height = 1,
      row = win_height + 5,
      col = col,
      style = "minimal",
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

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = body.buf,
    callback = function()
      pcall(vim.api.nvim_win_close, header.win, true)
      pcall(vim.api.nvim_win_close, footer.win, true)
    end,
  })

  return { header = header, body = body, footer = footer }
end

return M
