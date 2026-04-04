return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    opts = {
      ui = {
        border = "rounded",
        height = 0.85,
        width = 0.85,
        icons = {
          package_installed   = "✓",
          package_pending     = "⟳",
          package_uninstalled = "✗",
        },
      },
      max_concurrent_installers = 4,
    },
  },
}
