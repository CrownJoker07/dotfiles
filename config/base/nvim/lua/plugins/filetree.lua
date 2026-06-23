return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "2.*",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- 文件图标依赖
    },
    keys = {
      {
        "<leader>e",
        function()
          local api = require("nvim-tree.api")

          -- 如果当前焦点已经在 nvim-tree 内，则关闭 tree
          if vim.bo.filetype == "NvimTree" then
            api.tree.close()
          else
            -- 否则打开 tree，并自动定位到当前正在编辑的文件
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
      -- 定义 nvim-tree 内部的快捷键绑定
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")

        -- 辅助函数：统一快捷键配置选项
        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        -- 保留官方默认快捷键（a 新建、r 重命名、d 删除、c 复制、x 剪切、p 粘贴等）
        api.map.on_attach.default(bufnr)

        -- h: 关闭当前目录（类似回到上级）
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        -- H: 折叠所有目录
        vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))

        -- l: 打开文件或目录。如果是文件，打开后自动关闭 tree
        vim.keymap.set("n", "l", function()
          local node = api.tree.get_node_under_cursor()

          if node and node.nodes then
            -- 是目录：展开/收起
            api.node.open.edit()
          else
            -- 是文件：打开后关闭 tree
            api.node.open.edit()
            api.tree.close()
          end
        end, opts("Open File Or Directory"))

        -- L: 竖分屏打开文件，但焦点留在 tree（方便连续打开多个文件）
        vim.keymap.set("n", "L", function()
          local node = api.tree.get_node_under_cursor()

          if node and node.nodes then
            -- 是目录：正常展开
            api.node.open.edit()
          else
            -- 是文件：竖分屏打开，但焦点不跳转
            api.node.open.vertical()
            api.tree.focus()
          end
        end, opts("Open Vertical Split"))
      end

      return {
        on_attach = on_attach, -- 绑定上面定义的快捷键

        hijack_cursor = true, -- 光标跟随节点移动，不会独立移动

        -- 窗口外观配置
        view = {
          width = 32, -- 宽度 32 列
          side = "left", -- 显示在左侧
          preserve_window_proportions = true, -- 打开/关闭时保持窗口比例
        },

        -- 渲染相关配置
        renderer = {
          group_empty = true, -- 合并空的单层目录（如 a/b/c 显示为 a/b/c）

          -- 显示文件夹层级的缩进线，更直观
          indent_markers = {
            enable = true,
          },

          -- 高亮显示 git 状态、已打开文件、修改过的文件
          highlight_git = "icon",
          highlight_opened_files = "name",
          highlight_modified = "name",

          -- 图标显示配置
          icons = {
            show = {
              file = true, -- 文件图标
              folder = true, -- 文件夹图标
              folder_arrow = true, -- 文件夹展开/收起箭头（▶/▼）
              git = true, -- git 状态图标（✗、+、~ 等）
              modified = true, -- 修改标记图标
              diagnostics = true, -- LSP 诊断图标（错误、警告等）
            },
          },
        },

        -- 切换文件时自动定位 tree 到当前文件
        update_focused_file = {
          enable = true,
          update_root = {
            enable = false, -- 不自动改变 tree 的根目录，避免突然跳目录
          },
        },

        -- git 状态显示
        git = {
          enable = true,
          show_on_dirs = true, -- 目录也显示 git 状态
          show_on_open_dirs = true, -- 只在展开的目录显示
        },

        -- LSP 诊断信息（错误、警告）显示
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },

        -- 修改标记（文件被修改但未保存）
        modified = {
          enable = true,
          show_on_dirs = true,
        },

        -- 过滤器：控制哪些文件显示/隐藏
        filters = {
          dotfiles = false, -- false = 显示 dotfiles（.gitignore、.env 等）
          git_ignored = true, -- 隐藏 git ignored 的文件（node_modules、Library 等）
          custom = {
            "^\\.git$", -- 额外隐藏 .git 目录
          },
        },

        actions = {
          open_file = {
            resize_window = false, -- 打开文件后不自动调整窗口大小
          },
        },
      }
    end,
  },
}
