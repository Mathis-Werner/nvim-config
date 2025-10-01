return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts = {
    ensure_installed = {
      -- Lua
      "stylua",
      "luacheck",
      "lua-language-server",

      -- C++
      "clangd",
      "cpplint",
      "clang-format",

      -- Shell
      "shfmt",
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)

    local registry = require("mason-registry")
    registry:on("package:install:success", function()
      vim.defer_fn(function()
        vim.cmd("doautocmd FileType")
      end, 100)
    end)

    registry.refresh(function()
      for _, tool in ipairs(opts.ensure_installed) do
        local pkg = registry.get_package(tool)
        if not pkg:is_installed() then
          pkg:install()
        end
      end
    end)
  end,
}

