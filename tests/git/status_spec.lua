local parse_line = require("git.status")._parse_line

describe("parse_status", function()
  it("parses lines correctly with 'X' and 'Y' fields", function()
    local lines = {
      "M  path/to/file1.lua", -- Modified (staged)
      " M path/to/file1.lua", -- Modified (not staged)
      " A path/to/file2.lua", -- Added (not staged)
      "A  path/to/file2.lua", -- Added (staged)
      "D  path/to/file3.lua", -- Deleted (staged)
      "R  path/to/file4.lua -> path/to/file4_renamed.lua", -- Renamed (staged)
      "C  path/to/file5.lua", -- Copied (staged)
      " U path/to/file6.lua", -- Unmerged (not staged)
      "T  path/to/file7.lua", -- Type changed (staged)
      "?? path/to/file9.lua", -- Untracked (not staged)
    }

    local expected_results = {
      { change_type = "modification", staged = true, path = "path/to/file1.lua" },
      { change_type = "modification", staged = false, path = "path/to/file1.lua" },
      { change_type = "addition", staged = false, path = "path/to/file2.lua" },
      { change_type = "addition", staged = true, path = "path/to/file2.lua" },
      { change_type = "deletion", staged = true, path = "path/to/file3.lua" },
      {
        change_type = "rename",
        staged = true,
        path = "path/to/file4.lua -> path/to/file4_renamed.lua",
      },
      { change_type = "unknown", staged = true, path = "path/to/file5.lua" },
      { change_type = "unknown", staged = false, path = "path/to/file6.lua" },
      { change_type = "modification", staged = true, path = "path/to/file7.lua" },
      { change_type = "addition", staged = false, path = "path/to/file9.lua" },
    }

    for i, line in ipairs(lines) do
      local result = parse_line(line)
      assert.are.same(expected_results[i], result)
    end
  end)

  it("returns an error for invalid input", function()
    local invalid_lines = {
      "",
      "   ",
      "invalidformat",
      "XY",
    }
    for _, line in ipairs(invalid_lines) do
      local result, err = parse_line(line)
      assert.is_nil(result)
      assert.is_not_nil(err)
    end
  end)
end)
