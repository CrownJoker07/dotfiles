return {
  {
    "voldikss/vim-translator",
    cmd = {
      "Translate",
      "TranslateW",
      "TranslateR",
      "TranslateX",
    },
    init = function()
      vim.g.translator_target_lang = "zh"
      vim.g.translator_source_lang = "auto"
      vim.g.translator_default_engines = { "bing", "haici" }
    end,
    keys = {
      {
        "<leader>tw",
        "<cmd>TranslateW<CR>",
        mode = "n",
        desc = "Translate word",
      },
      {
        "<leader>tw",
        ":TranslateW --engines=google<CR>",
        mode = "v",
        desc = "Translate selection",
      },
    },
  },
}
