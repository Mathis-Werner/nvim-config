return {
  "mfussenegger/nvim-lint",
  -- Event to trigger linters
  events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    linters_by_ft = {
      lua = { "luacheck" },
      cpp = { "cppcheck" },
    }
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      callback = function() lint.try_lint() end,
    })
  end,
}
