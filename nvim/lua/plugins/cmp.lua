local config = function(_, _)
    local cmp = require('cmp')
    cmp.setup.buffer({
      sources = { { name = "nvim_lsp" }}
    })
  end

return {
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    dependencies = "hrsh7th/nvim-cmp",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = "hrsh7th/nvim-cmp",
    config = config,
  },
}
