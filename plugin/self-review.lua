vim.api.nvim_create_user_command("SelfReview", function()
  require("self-review").open_floatwin()
end, {})
