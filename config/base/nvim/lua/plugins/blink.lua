return {
  {
    "saghen/blink.cmp",
    -- Use tagged releases so blink can download prebuilt fuzzy matcher binaries.
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
