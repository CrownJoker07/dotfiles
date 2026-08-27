return {
  name = "mpls",
  config = {
    cmd = {
      vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "mpls"),
      "--no-auto",
      "--tabs",
      "--theme",
      "dark",
    },
    filetypes = {
      "markdown",
    },
    root_markers = {
      ".marksman.toml",
      ".git",
    },
    handlers = {
      ["window/showDocument"] = function(err, params, ctx, config)
        if params and params.uri and not params.uri:match("^%a[%w+.-]*:") then
          params = vim.deepcopy(params)
          params.uri = vim.uri_from_fname(params.uri)
        end

        return vim.lsp.handlers["window/showDocument"](err, params, ctx, config)
      end,
    },
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function(args)
          client:notify("mpls/editorDidChangeFocus", {
            uri = vim.uri_from_bufnr(args.buf),
          })
        end,
        desc = "Notify mpls when a Markdown buffer gains focus",
      })

      vim.api.nvim_buf_create_user_command(bufnr, "MplsOpenPreview", function()
        client:exec_cmd({
          title = "Preview Markdown with mpls",
          command = "open-preview",
        })
      end, { desc = "Preview Markdown with mpls" })

      vim.keymap.set("n", "<leader>mp", "<cmd>MplsOpenPreview<cr>", {
        buffer = bufnr,
        desc = "Open Markdown preview",
      })
    end,
  },
}
