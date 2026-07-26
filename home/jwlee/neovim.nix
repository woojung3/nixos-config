{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      clang-tools
      nil
      nixfmt
      lua-language-server
      pyright
      jdt-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      telescope-nvim
      plenary-nvim
      nvim-tree-lua
      nvim-web-devicons
      lualine-nvim
      gitsigns-nvim
      nvim-treesitter.withAllGrammars
    ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.hlsearch = true
      vim.opt.wrap = false
      vim.opt.smartindent = true
      vim.opt.expandtab = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.mouse = "a"
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      vim.opt.updatetime = 250

      local palette = {
        bg = "#${c.background}",
        surface = "#${c.surface}",
        raised = "#${c.surfaceRaised}",
        fg = "#${c.foreground}",
        muted = "#${c.muted}",
        accent = "#${c.accent}",
        accentSoft = "#${c.accentSoft}",
        secondary = "#${c.secondary}",
        olive = "#${c.olive}",
        urgent = "#${c.urgent}",
      }

      vim.cmd("highlight clear")
      vim.g.colors_name = "bloom"
      local highlights = {
        Normal = { fg = palette.fg, bg = palette.bg },
        NormalFloat = { fg = palette.fg, bg = palette.surface },
        FloatBorder = { fg = palette.accent, bg = palette.surface },
        CursorLine = { bg = palette.surface },
        LineNr = { fg = palette.muted },
        CursorLineNr = { fg = palette.accent, bold = true },
        Visual = { bg = palette.raised },
        Search = { fg = palette.bg, bg = palette.accent },
        Comment = { fg = palette.muted, italic = true },
        String = { fg = palette.olive },
        Function = { fg = palette.secondary },
        Identifier = { fg = palette.fg },
        Keyword = { fg = palette.accent },
        Type = { fg = palette.accentSoft },
        DiagnosticError = { fg = palette.urgent },
        DiagnosticWarn = { fg = palette.accentSoft },
        DiagnosticInfo = { fg = palette.secondary },
        Pmenu = { fg = palette.fg, bg = palette.surface },
        PmenuSel = { fg = palette.bg, bg = palette.accent },
      }
      for group, opts in pairs(highlights) do vim.api.nvim_set_hl(0, group, opts) end

      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = { width = 34 },
        renderer = { group_empty = true, highlight_git = true },
      })
      require("gitsigns").setup()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
        },
      })

      require("lualine").setup({
        options = {
          icons_enabled = false,
          component_separators = "",
          section_separators = "",
          theme = {
            normal = {
              a = { fg = palette.bg, bg = palette.accent, gui = "bold" },
              b = { fg = palette.fg, bg = palette.raised },
              c = { fg = palette.muted, bg = palette.surface },
            },
            insert = { a = { fg = palette.bg, bg = palette.olive, gui = "bold" } },
            visual = { a = { fg = palette.bg, bg = palette.secondary, gui = "bold" } },
            replace = { a = { fg = palette.bg, bg = palette.urgent, gui = "bold" } },
            inactive = {
              a = { fg = palette.muted, bg = palette.surface },
              b = { fg = palette.muted, bg = palette.surface },
              c = { fg = palette.muted, bg = palette.surface },
            },
          },
        },
      })

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "path" } }, { { name = "buffer" } }),
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })
      vim.lsp.enable({ "clangd", "pyright", "jdtls", "nil_ls", "lua_ls" })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Documentation" })
      vim.keymap.set({ "n", "v" }, "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })
      vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeOpen<cr>", { desc = "Open file tree" })
      vim.keymap.set("n", "<leader>c", "<cmd>NvimTreeClose<cr>", { desc = "Close file tree" })
      vim.keymap.set("n", "<leader><space>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>", { desc = "Search text" })
    '';
  };
}
