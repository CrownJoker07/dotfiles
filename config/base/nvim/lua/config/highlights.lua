local function apply()
  local links = {
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@constructor"] = "Type",
    ["@function"] = "Function",
    ["@function.method"] = "Function",
    ["@function.call"] = "Statement",
    ["@function.method.call"] = "Statement",
    ["@variable.parameter"] = "Special",
    ["@variable.member"] = "PreProc",
    ["@property"] = "PreProc",
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",

    ["@lsp.type.class"] = "Type",
    ["@lsp.type.struct"] = "Type",
    ["@lsp.type.interface"] = "Type",
    ["@lsp.type.enum"] = "Type",
    ["@lsp.type.typeParameter"] = "Type",
    ["@lsp.type.function"] = "Function",
    ["@lsp.type.method"] = "Function",
    ["@lsp.type.parameter"] = "Special",
    ["@lsp.type.property"] = "PreProc",
    ["@lsp.type.field"] = "PreProc",
    ["@lsp.type.enumMember"] = "Constant",
    ["@lsp.type.namespace"] = "Special",
    ["@lsp.type.macro"] = "PreProc",
    ["@lsp.type.decorator"] = "PreProc",
  }

  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("config_semantic_highlights", { clear = true }),
  desc = "Add subtle Treesitter and LSP semantic highlights",
  callback = apply,
})

apply()
