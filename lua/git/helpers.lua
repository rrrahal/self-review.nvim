local M = {}
M.get_file_versions = function()
  local Job = require("plenary.job")
  local result_old, result_new = {}, {}

  -- Get the old version from HEAD
  Job:new({
    command = "git",
    args = { "show", "HEAD:lua/self-review.lua" },
    on_exit = function(j)
      result_old = j:result()
    end,
  }):sync()

  -- Get the new version from the working tree
  Job:new({
    command = "cat",
    args = { "lua/self-review.lua" },
    on_exit = function(j)
      result_new = j:result()
    end,
  }):sync()

  return result_old, result_new
end

M.get_hunks_with_context = function()
  local Job = require("plenary.job")
  local result = {}

  Job:new({
    command = "git",
    args = { "diff", "--unified=3", "--color=never", "lua/self-review.lua" },
    on_exit = function(j, return_val)
      if return_val == 0 then
        result = j:result()
      else
        print("Error running git diff:", table.concat(j:stderr_result(), "\n"))
      end
    end,
  }):sync()

  return result
end
