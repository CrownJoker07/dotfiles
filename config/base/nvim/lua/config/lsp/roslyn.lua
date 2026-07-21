local root_markers = { ".sln", ".slnx", ".slnf", ".csproj", ".git" }

return {
  name = "roslyn",
  config = {
    cmd = {
      "roslyn-language-server",
      "--stdio",
    },
    cmd_env = {
      Configuration = vim.env.Configuration or "Debug",
      TMPDIR = vim.env.TMPDIR and vim.fn.resolve(vim.env.TMPDIR) or nil,
    },
    filetypes = {
      "cs",
      "razor",
      "cshtml",
    },
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, function(name)
        return vim.iter(root_markers):any(function(marker)
          return name:sub(-#marker) == marker
        end)
      end)

      if root then
        on_dir(root)
      end
    end,
    on_init = function(client)
      for entry, type in vim.fs.dir(client.config.root_dir) do
        if type == "file" and entry:match("%.slnx?$") then
          client:notify("solution/open", {
            solution = vim.uri_from_fname(vim.fs.joinpath(client.config.root_dir, entry)),
          })
          return
        end
      end
    end,
    settings = {
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_indexer_parameters = true,
        dotnet_enable_inlay_hints_for_literal_parameters = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        dotnet_enable_inlay_hints_for_other_parameters = true,
        dotnet_enable_inlay_hints_for_parameters = true,
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      },
      ["csharp|completion"] = {
        dotnet_show_completion_items_from_unimported_namespaces = true,
        dotnet_show_name_completion_suggestions = true,
      },
      ["csharp|formatting"] = {
        dotnet_organize_imports_on_format = true,
      },
    },
  },
}
