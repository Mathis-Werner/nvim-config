return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      local diagnostic_icons = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN]  = "",
        [vim.diagnostic.severity.HINT]  = "",
        [vim.diagnostic.severity.INFO]  = "",
      }

      local diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = function(diagnostic)
            return diagnostic_icons[diagnostic.severity] or "●"
          end,
        },
        severity_sort = true,
        signs = {
          text = diagnostic_icons,
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      }

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
        stylua = false,
      }

      return {
        diagnostics = diagnostics,
        capabilities = capabilities,
        servers = servers,
        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },
        codelens = {
          enabled = false,
        },
        folds = {
          enabled = true,
        },
        setup = {},
        format = {},
      }
    end,
    config = function(_, opts)

      -- Setup diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Define signs
      for severity, icon in pairs(opts.diagnostics.signs.text) do
        local name = ({
          [vim.diagnostic.severity.ERROR] = "Error",
          [vim.diagnostic.severity.WARN]  = "Warn",
          [vim.diagnostic.severity.HINT]  = "Hint",
          [vim.diagnostic.severity.INFO]  = "Info",
        })[severity]

        vim.fn.sign_define("DiagnosticSign" .. name, {
          text = icon,
          texthl = "DiagnosticSign" .. name,
          numhl = "",
        })
      end

      -- Define your custom on_attach function here
      local function on_attach(client, bufnr)
        -- Example keymap setup
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "K", vim.lsp.buf.hover, "Hover info")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

        -- Inlay hints
        if opts.inlay_hints.enabled and vim.lsp.inlay_hint then
          local ft = vim.bo[bufnr].filetype
          if not vim.tbl_contains(opts.inlay_hints.exclude, ft) then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end

        -- Codelens
        if opts.codelens.enabled and vim.lsp.codelens then
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
          })
        end
      end

      -- Setup all servers
      local servers = opts.servers or {}
      for server, server_opts in pairs(servers) do
        if server_opts ~= false then
          server_opts = server_opts == true and {} or server_opts
          server_opts.capabilities = vim.tbl_deep_extend("force", {}, opts.capabilities or {}, server_opts.capabilities or {})
          server_opts.on_attach = on_attach
          --vim.lsp.config(server, server_opts)
          vim.lsp.enable({ "lua" })
        end
      end
    end,
  },

  -- mason
  {
    "williamboman/mason.nvim",
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
  },

  -- mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "clangd" },
      automatic_installation = true,
    },
  },
}

