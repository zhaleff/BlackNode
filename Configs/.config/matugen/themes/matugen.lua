local lush = require("lush")
local hsl = lush.hsl

return lush(function()
  return {
    Normal({
      fg = hsl(0, 0, 95),
      bg = hsl(220, 15, 8),
    }),

    Comment({
      fg = hsl(220, 10, 45),
      gui = "italic",
    }),

    Function({
      fg = hsl(260, 80, 70),
    }),

    Keyword({
      fg = hsl(180, 70, 70),
    }),

    String({
      fg = hsl(90, 60, 65),
    }),

    Type({
      fg = hsl(220, 90, 75),
    }),

    ["@function"]({
      fg = hsl(260, 80, 70),
    }),

    ["@keyword"]({
      fg = hsl(180, 70, 70),
    }),

    ["@string"]({
      fg = hsl(90, 60, 65),
    }),

    ["@type"]({
      fg = hsl(220, 90, 75),
    }),
  }
end)
