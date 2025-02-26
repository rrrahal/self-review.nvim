# SelfReview

**SelfReview** is a Neovim plugin that helps you review your work before committing. It creates a floating window displaying the current changes in your Git repository, allowing you to navigate and visually inspect modifications without breaking your Vim flow.

## Demo
![Kapture 2025-02-21 at 15 23 04](https://github.com/user-attachments/assets/fb125aa1-34fc-47f6-bbfe-73425272d2ec)




## Installation

If you're using [Lazy.nvim](https://github.com/folke/lazy.nvim), add the following block to your configuration:

```lua
return {
  {
    "rrrahal/self-review.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local self_review = require("self-review")
      -- (Optional) you can set up a keybind here
      vim.keymap.set("n", "<leader>r", self_review.start_diff, {})
    end,
  },
}
```

## Configuration

Currently, there are no customization options, but support for customization will be added in future updates.

## Usage
Once installed, *SelfReview* provides the SelfReview command. You can assign it to your preferred keybind and start using it.
```vim
:SelfReview
```

You can use the following keybinds inside the floating window:
- `n` to go to the next diff
- `p` to go to the previous diff
- `q` to quit the current floating window 


----

## Development

### Running Tests
You can run tests using [Plenary.nvim](https://github.com/nvim-lua/plenary.nvim):


- Run a single file
```vim
:PlenaryBustedFile %
```

- Run tests in a directory
```vim
:PlenaryBustedDirectory <path>
```
