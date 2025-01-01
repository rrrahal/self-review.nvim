local parse_lines = require("git.status")._parse_status_lines

describe("parse_status_lines", function()
  -- parsed the input given the spec: https://git-scm.com/docs/git-status#_short_format
  it("parses lines correctly with 'X' and 'Y' fields", function()
    local lines = {
      "M  path/to/file1.lua", -- Modified
      "A  path/to/file2.lua", -- Added
      "D  path/to/file3.lua", -- Deleted
      "R  path/to/file4.lua -> path/to/file4_renamed.lua", -- Renamed
      "C  path/to/file5.lua", -- Copied (if status.renames is set to "copies")
      "U  path/to/file6.lua", -- Unmerged
      "T  path/to/file7.lua", -- Type changed
      "?? path/to/file9.lua", -- Untracked file
    }

    local result = parse_lines(lines)

    assert.are.same({
      { type = "M", path = "path/to/file1.lua" }, -- Modified
      { type = "A", path = "path/to/file2.lua" }, -- Added
      { type = "D", path = "path/to/file3.lua" }, -- Deleted
      { type = "R", path = "path/to/file4.lua", new_path = "path/to/file4_renamed.lua" }, -- Renamed
      { type = "C", path = "path/to/file5.lua" }, -- Copied
      { type = "U", path = "path/to/file6.lua" }, -- Unmerged
      { type = "T", path = "path/to/file7.lua" }, -- Type changed
      { type = "??", path = "path/to/file9.lua" }, -- Unmodified
    }, result)
  end)

  it("handles lines with no file path (empty path)", function()
    local lines = {
      " M ",
      " A ",
    }
    local result = parse_lines(lines)

    assert.are.same({
      { type = "M", path = "" },
      { type = "A", path = "" },
    }, result)
  end)

  it("trims whitespace around lines", function()
    local lines = {
      "  M  path/to/file.lua  ",
      "  A  another/file.txt  ",
      "  ?? some/other/file.txt  ",
    }
    local result = parse_lines(lines)

    assert.are.same({
      { type = "M", path = "path/to/file.lua" },
      { type = "A", path = "another/file.txt" },
      { type = "??", path = "some/other/file.txt" },
    }, result)
  end)

  it("returns an empty table for empty input", function()
    local lines = {}
    local result = parse_lines(lines)
    assert.are.same({}, result)
  end)
end)
