return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },          -- Lazy-load when opening files – keeps startup snappy
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Extra power for selecting/moving code blocks
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Parsers to install – covers everything you use daily (web, python, lua, config files, etc.)
        ensure_installed = {
          "lua", "luadoc", "vim", "vimdoc",
          "python",
          "javascript", "typescript", "tsx", "jsx",
          "html", "css", "scss", "tailwind",
          "json", "jsonc", "yaml", "toml",
          "markdown", "markdown_inline",
          "bash", "regex",
          "php", "blade", "vue", "svelte", "astro",
          "git_rebase", "git_commit", "gitignore",
          "query", -- For Treesitter queries (useful for dev)
        },

        -- Auto-install missing parsers when entering a buffer
        auto_install = true,

        -- Core modules
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false, -- Pure Treesitter – cleaner and faster
          disable = function(lang, buf)
            -- Disable for massive files to avoid lag
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },

        indent = {
          enable = true,
          -- Python indent can be flaky in some cases – disable if it annoys you
          -- disable = { "python" },
        },

        -- Incremental selection – press <C-space> to grow selection by Treesitter nodes (brilliant for code blocks)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },

        -- Textobjects – super useful for moving/selecting/swap functions, classes, parameters, etc.
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jumplist for <C-o>/<C-i>
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>sp"] = "@parameter.inner", -- Swap parameters
            },
            swap_previous = {
              ["<leader>sP"] = "@parameter.inner",
            },
          },
        },
      })

      -- Optional: fold using Treesitter (nice with Catppuccin)
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false -- Start with folds closed – toggle with za/zm/zr
    end,
  },
}
