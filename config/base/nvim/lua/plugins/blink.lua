return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = {
      "InsertEnter",
      "CmdlineEnter",
    },
    opts = {
      keymap = {
        preset = "super-tab",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
    },
  },
}
