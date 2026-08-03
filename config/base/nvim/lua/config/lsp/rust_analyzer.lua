return {
  name = "rust_analyzer",
  config = {
    cmd = {
      "rust-analyzer",
    },
    filetypes = {
      "rust",
    },
    root_markers = {
      "Cargo.toml",
      "rust-project.json",
      ".git",
    },
  },
}
