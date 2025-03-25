{ config, pkgs, ... }:

{
  programs.nixvim = {
    config = {
      enable = true;
      
      options = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        expandtab = true;
        wrap = false;
        ignorecase = true;
        smartcase = true;
      };

      globals.mapleader = " ";

      extraConfigLua = ''
        -- Function to read colors from pywal cache
        local function get_pywal_colors()
          local colors = {}
          local cache_path = os.getenv("HOME") .. "/.cache/wal/colors.lua"

          -- Check if the colors.lua file exists
          local f = io.open(cache_path, "r")
          if f then
            f:close()
            -- Use dofile to load the colors
            colors = dofile(cache_path)
          else
            -- Fallback colors if pywal cache doesn't exist
            colors = {
              background = "#1a1b26",
              foreground = "#c0caf5",
              cursor = "#c0caf5",
              color0 = "#15161e",
              color1 = "#f7768e",
              color2 = "#9ece6a",
              color3 = "#e0af68",
              color4 = "#7aa2f7",
              color5 = "#bb9af7",
              color6 = "#7dcfff",
              color7 = "#a9b1d6",
              color8 = "#414868",
              color9 = "#f7768e",
              color10 = "#9ece6a",
              color11 = "#e0af68",
              color12 = "#7aa2f7",
              color13 = "#bb9af7",
              color14 = "#7dcfff",
              color15 = "#c0caf5"
            }
          end

          return colors
        end

        -- Apply the pywal colors to Neovim
        local function apply_pywal_colors()
          local colors = get_pywal_colors()

          -- Set terminal colors
          vim.g.terminal_color_0 = colors.color0
          vim.g.terminal_color_1 = colors.color1
          vim.g.terminal_color_2 = colors.color2
          vim.g.terminal_color_3 = colors.color3
          vim.g.terminal_color_4 = colors.color4
          vim.g.terminal_color_5 = colors.color5
          vim.g.terminal_color_6 = colors.color6
          vim.g.terminal_color_7 = colors.color7
          vim.g.terminal_color_8 = colors.color8
          vim.g.terminal_color_9 = colors.color9
          vim.g.terminal_color_10 = colors.color10
          vim.g.terminal_color_11 = colors.color11
          vim.g.terminal_color_12 = colors.color12
          vim.g.terminal_color_13 = colors.color13
          vim.g.terminal_color_14 = colors.color14
          vim.g.terminal_color_15 = colors.color15

          -- Set editor colors
          vim.cmd('highlight Normal guifg=' .. colors.foreground .. ' guibg=' .. colors.background)
          vim.cmd('highlight LineNr guifg=' .. colors.color8)
          vim.cmd('highlight CursorLineNr guifg=' .. colors.color3)
          vim.cmd('highlight Pmenu guibg=' .. colors.color0)
          vim.cmd('highlight PmenuSel guibg=' .. colors.color8)
          vim.cmd('highlight Comment guifg=' .. colors.color4)
          vim.cmd('highlight Constant guifg=' .. colors.color6)
          vim.cmd('highlight Special guifg=' .. colors.color5)
          vim.cmd('highlight Identifier guifg=' .. colors.color4)
          vim.cmd('highlight Statement guifg=' .. colors.color3)
          vim.cmd('highlight PreProc guifg=' .. colors.color5)
          vim.cmd('highlight Type guifg=' .. colors.color2)
          vim.cmd('highlight Underlined guifg=' .. colors.color6)
          vim.cmd('highlight Todo guifg=' .. colors.color7 .. ' guibg=' .. colors.color1)
          vim.cmd('highlight Search guifg=' .. colors.background .. ' guibg=' .. colors.color3)
          vim.cmd('highlight Visual guibg=' .. colors.color8)
          vim.cmd('highlight Cursor guifg=' .. colors.background .. ' guibg=' .. colors.foreground)

          -- Customize status line colors if using lualine
          if package.loaded["lualine"] then
            require('lualine').setup {
              options = {
                theme = {
                  normal = {
                    a = {bg = colors.color4, fg = colors.background, gui = 'bold'},
                    b = {bg = colors.color8, fg = colors.foreground},
                    c = {bg = colors.background, fg = colors.foreground}
                  },
                  insert = {
                    a = {bg = colors.color2, fg = colors.background, gui = 'bold'}
                  },
                  visual = {
                    a = {bg = colors.color3, fg = colors.background, gui = 'bold'}
                  },
                  replace = {
                    a = {bg = colors.color1, fg = colors.background, gui = 'bold'}
                  },
                  inactive = {
                    a = {bg = colors.color8, fg = colors.foreground, gui = 'bold'},
                    b = {bg = colors.color8, fg = colors.foreground},
                    c = {bg = colors.background, fg = colors.foreground}
                  }
                }
              }
            }
          end
        end

        -- Create an autocmd to apply colors on startup and when colorscheme changes
        vim.api.nvim_create_autocmd({"VimEnter", "ColorScheme"}, {
          callback = function()
            apply_pywal_colors()
          end
        })

        -- Apply colors immediately
        apply_pywal_colors()

        -- Define key mappings directly in Lua
        vim.g.mapleader = " "
        
        -- Telescope mappings
        vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, desc = "Find files" })
        vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, desc = "Live grep" })
        
        -- NvimTree mapping
        vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>NvimTreeToggle<CR>', { noremap = true, desc = "Toggle file explorer" })
        
        -- Setup nvim-cmp
        require('cmp').setup({
          sources = {
            { name = 'nvim_lsp' },
            { name = 'path' },
            { name = 'buffer' }
          }
        })
      '';

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
            rust-analyzer.enable = true;
            pyright.enable = true;
          };
        };

        # Use the updated format for nvim-cmp
        cmp = {
          enable = true;
          # Instead of using sources here, we set them up in Lua code above
        };
      };
    };
  };
}
