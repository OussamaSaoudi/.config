return {
 {
      'saecki/crates.nvim',
      event = { "BufRead Cargo.toml" },
      config = function()
          require('crates').setup()
      end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function ()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    server = {
      on_attach = require("nvchad.configs.lspconfig").on_attach,
      default_settings = {
        -- rust-analyzer language server configuration
        ['rust-analyzer'] = {
          allFeatures = true
        },
      },
    },
  },
}
