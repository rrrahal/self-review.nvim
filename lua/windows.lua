local styles = require("windows_styles")
local utils = require("utils")

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

  -- default lang
  local lang = "plaintext"

  local function update_header(buf, header_text, filename)
    vim.bo[buf].modifiable = true

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, header_text)
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

  local function set_header(filename, staged)
    -- TODO: fix formatted filename
    -- local formatted_filename = utils.format_filename(filename)

    local content_str = table.concat({ filename }, " ")

    local staged_phrase = "STAGED"
    if not staged then
      staged_phrase = "NOT STAGED"
    end

    local screen_width = vim.api.nvim_win_get_width(0)
    local padding = string.rep(" ", screen_width - #staged_phrase - 2 - #content_str)

    local header_text = { content_str .. padding .. staged_phrase }
    update_header(header.buf, header_text, filename, staged)

    local hl_group = staged and "DiffAdd" or "DiffDelete"
    vim.api.nvim_buf_add_highlight(header.buf, -1, hl_group, 0, #content_str + #padding, -1)
  end

  local function set_footer(content)
    local content_str = table.concat(content, " ")

    local footer_phrase = "g: goto buffer | n: next | p: previous | q: quit"

    local screen_width = vim.api.nvim_win_get_width(0)
    local padding = string.rep(" ", screen_width - #content_str - 2 - #footer_phrase)

    local footer_text = { content_str .. padding .. footer_phrase }

    update_footer(footer.buf, footer_text)
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
