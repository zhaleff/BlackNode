return {
  "nomnivore/ollama.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "Ollama",
    "OllamaModel",
    "OllamaServe",
    "OllamaStatus",
  },
  opts = {
    model = "qwen2.5-coder:3b",
    url = "http://127.0.0.1:11434",
    serve = {
      on_start = false,
    },
  },
}
