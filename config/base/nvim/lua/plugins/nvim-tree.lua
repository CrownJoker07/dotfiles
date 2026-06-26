return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>e",
        function()
          local api = require("nvim-tree.api")

          if vim.bo.filetype == "NvimTree" then
            api.tree.close()
          else
            api.tree.find_file({
              open = true,
              focus = true,
            })
          end
        end,
        desc = "Explorer: Toggle / Focus current file",
      },
    },
    opts = function()
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        local function is_directory(node)
          return node and node.nodes
        end

        -- Keep the default mappings, then layer the file-manager style h/l overrides.
        api.map.on_attach.default(bufnr)

        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))

        vim.keymap.set("n", "l", function()
          local node = api.tree.get_node_under_cursor()

          if is_directory(node) then
            api.node.open.edit()
          else
            api.node.open.edit()
            api.tree.close()
          end
        end, opts("Open File Or Directory"))

        vim.keymap.set("n", "L", function()
          local node = api.tree.get_node_under_cursor()

          if is_directory(node) then
            api.node.open.edit()
          else
            api.node.open.vertical()
            api.tree.focus()
          end
        end, opts("Open Vertical Split"))
      end

      return {
        on_attach = on_attach,

        hijack_cursor = true,

        view = {
          width = 32,
          side = "left",
          preserve_window_proportions = true,
        },

        renderer = {
          group_empty = true,
          indent_markers = {
            enable = true,
          },
          highlight_git = "icon",
          highlight_opened_files = "name",
          highlight_modified = "name",
        },

        update_focused_file = {
          enable = true,
        },

        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },

        modified = {
          enable = true,
        },

        filters = {
          custom = {
            "^\\.git$",
          },
        },

        actions = {
          open_file = {
            resize_window = false,
          },
        },
      }
    end,
  },
}
