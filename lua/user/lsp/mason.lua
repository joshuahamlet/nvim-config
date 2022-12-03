local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end

local mason_lspconfig = require("mason-lspconfig")

local lspconfig = require("lspconfig")

local servers = { "jsonls", "sumneko_lua" }

mason.setup({
  ui = {border = 'rounded'}
})
mason_lspconfig.setup({
	ensure_installed = servers,
})

for _, server in pairs(servers) do
	local opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}
	local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.settings." .. server)
	if has_custom_opts then
		opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
	end
	lspconfig[server].setup(opts)
end

local default_handler = function(server)
  -- See :help lspconfig-setup
  local opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
    settings = {
      Lua = {
        diagnostics = { globals = {'vim'} }
      }
    }
	}
  lspconfig[server].setup(opts)
end

-- See :help mason-lspconfig-dynamic-server-setup
mason_lspconfig.setup_handlers({
  default_handler,
  ['tsserver'] = function()
    lspconfig.tsserver.setup({
      settings = {
        completions = {
          completeFunctionCalls = true
        }
      }
    })
  end
})
