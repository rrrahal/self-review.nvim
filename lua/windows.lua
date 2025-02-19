local styles = require("windows_styles")
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

  -- removes the cursor from the created windows
  for _, win in ipairs({ header, body, footer }) do
    vim.api.nvim_win_set_option(win.win, "winhl", "Normal:NormalNC,Cursor:NormalNC,CursorLine:NormalNC")
  end

  local lang = "plaintext"

  local function update_header(buf, filename)
    vim.bo[buf].modifiable = true

    local centered_title = " " .. filename .. " "
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { centered_title })
    styles.apply_header_styles(buf)

    -- sets the filetype, important to attach treesitter
    local ft = vim.filetype.match({ filename = filename, buf = buf }) or "plaintext"
    lang = ft

    vim.bo[buf].modifiable = false
  end

  local function update_footer(buf, content)
    vim.bo[buf].modifiable = true

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    styles.apply_footer_styles(buf)

    vim.bo[buf].modifiable = false
  end

  local function update_body(buf, content)
    vim.bo[buf].modifiable = true

    local ok, err = pcall(vim.treesitter.start, buf, lang)
    if not ok then
      vim.notify("[SelfReview] " .. "treesitter could be attached on lang " .. lang, vim.log.levels.ERROR)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    styles.apply_body_styles(buf, content)

    vim.bo[buf].modifiable = false
  end

  local function set_header(filename)
    update_header(header.buf, filename)
  end

  local function set_footer(content)
    update_footer(footer.buf, content)
  end

  local function set_body(content)
    update_body(body.buf, content)
  end

  -- Cleanup windows when body is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = body.buf,
    callback = function()
      pcall(vim.api.nvim_win_close, header.win, true)
      pcall(vim.api.nvim_win_close, footer.win, true)
    end,
  })

  return {
    body = body,
    set_header = set_header,
    set_footer = set_footer,
    set_body = set_body,
  }
end

return M
