-- lspconfig
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

local inlay_hints = {
  enabled = true,
  exclude = { "vue" },
}
local codelens = {
  enabled = false,
}

-- Setup diagnostics
vim.diagnostic.config(diagnostics)

-- Define signs
for severity, icon in pairs(diagnostics.signs.text) do
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
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Example keymap setup
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "K", vim.lsp.buf.hover, "Hover info")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

    -- Inlay hints
    if inlay_hints.enabled and vim.lsp.inlay_hint then
      local ft = vim.bo[ev.buf].filetype
      if not vim.tbl_contains(inlay_hints.exclude, ft) then
        vim.lsp.inlay_hint.enable(true, { ev.buf})
      end
    end

    -- Codelens
    if codelens.enabled and vim.lsp.codelens then
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = ev.buf,
        callback = vim.lsp.codelens.refresh,
      })
    end
  end,
})

-- Setup all servers
vim.lsp.enable({ "lua", "clangd" })
