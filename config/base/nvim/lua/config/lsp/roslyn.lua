local function list_files_with_extensions(dir, extensions)
  local files = {}

  for name, type in vim.fs.dir(dir) do
    if type == "file" then
      for _, extension in ipairs(extensions) do
        if vim.endswith(name, extension) then
          files[#files + 1] = vim.fs.normalize(vim.fs.joinpath(dir, name))
          break
        end
      end
    end
  end

  table.sort(files)
  return files
end

local function find_solutions(bufnr)
  local solutions = vim.fs.find(function(name)
    return name:match("%.sln$") or name:match("%.slnx$") or name:match("%.slnf$")
  end, {
    upward = true,
    path = vim.api.nvim_buf_get_name(bufnr),
    limit = math.huge,
  })

  table.sort(solutions)
  return solutions
end

local function get_root(bufnr)
  local solutions = find_solutions(bufnr)
  if #solutions > 0 then
    return vim.fs.dirname(solutions[1])
  end

  local project = vim.fs.find(function(name)
    return name:match("%.csproj$") ~= nil
  end, {
    upward = true,
    path = vim.api.nvim_buf_get_name(bufnr),
  })[1]

  return project and vim.fs.dirname(project) or vim.fs.root(bufnr, ".git")
end

local function root_dir(bufnr, on_dir)
  local root = get_root(bufnr)
  if root then
    on_dir(root)
  end
end

local function on_init(client)
  if not client.config.root_dir then
    return
  end

  local solutions = list_files_with_extensions(client.config.root_dir, {
    ".sln",
    ".slnx",
    ".slnf",
  })

  if #solutions > 0 then
    client:notify("solution/open", {
      solution = vim.uri_from_fname(solutions[1]),
    })
    return
  end

  local projects = list_files_with_extensions(client.config.root_dir, { ".csproj" })
  if #projects > 0 then
    client:notify("project/open", {
      projects = vim.tbl_map(vim.uri_from_fname, projects),
    })
  end
end

return {
  name = "roslyn",
  config = {
    cmd = { "roslyn-language-server", "--stdio" },
    cmd_env = {
      Configuration = vim.env.Configuration or "Debug",
      TMPDIR = vim.env.TMPDIR and vim.fn.resolve(vim.env.TMPDIR) or nil,
    },
    filetypes = {
      "cs",
      "razor",
      "cshtml",
    },
    root_dir = root_dir,
    on_init = on_init,
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
