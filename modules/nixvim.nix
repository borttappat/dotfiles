{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    # Vim options
    options = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2;        # Tab width should be 2
      expandtab = true;      # Use spaces instead of tabs
      wrap = false;          # Don't wrap lines
      ignorecase = true;     # Ignore case when searching
      smartcase = true;      # Don't ignore case when searching with uppercase
    };

    # Colorscheme
    colorschemes.gruvbox.enable = true;

    # Plugins
    plugins = {
      lightline.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      lualine.enable = true;
      nvim-tree.enable = true;
      gitsigns.enable = true;
      which-key.enable = true;
      comment-nvim.enable = true;
      
      lsp = {
        enable = true;
        servers = {
          # Add language servers you want to use
          rust-analyzer.enable = true;
          pyright.enable = true;
          # Add more language servers as needed
        };
      };

      nvim-cmp = {
        enable = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
        ];
      };
    };

    # Keymappings
    globals.mapleader = " "; # Set leader key to space
    maps = {
      normal = {
        "<leader>ff" = {
          action = "<cmd>Telescope find_files<CR>";
          desc = "Find files";
        };
        "<leader>fg" = {
          action = "<cmd>Telescope live_grep<CR>";
          desc = "Live grep";
        };
        "<C-n>" = {
          action = "<cmd>NvimTreeToggle<CR>";
          desc = "Toggle file explorer";
        };
      };
    };

    # Additional Vim-script configurations
    extraConfigVim = ''
      set encoding=utf-8
      set mouse=a
    '';

    # Additional Lua configurations
    extraConfigLua = ''
      -- Add any Lua-based configurations here
    '';
  };
}
