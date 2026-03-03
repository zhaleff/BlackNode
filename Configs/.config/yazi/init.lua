require("git"):setup()

local mocha_palette = {
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  subtext1 = "#bac2de",
  subtext0 = "#a6adc8",
  overlay2 = "#9399b2",
  overlay1 = "#7f849c",
  overlay0 = "#6c7086",
  surface2 = "#585b70",
  surface1 = "#45475a",
  surface0 = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
}

th.git = th.git or {
    -- File status styles
    modified = ui.Style():fg("#569CD6"):bold(),  -- soft blue
    added = ui.Style():fg("#4EC9B0"),           -- teal
    deleted = ui.Style():fg("#F48771"):bold(),  -- soft red
    renamed = ui.Style():fg("#DCDCAA"),         -- light yellow
    untracked = ui.Style():fg("#C586C0"),       -- lavender
    ignored = ui.Style():fg("#858585"),         -- gray

    -- Status signs (can use icons if your font supports them)
    modified_sign = "",  -- or "M"
    added_sign = "",     -- or "A"
    deleted_sign = "",   -- or "D"
    renamed_sign = "➜",   -- or "R"
    untracked_sign = "?",
    ignored_sign = "!",

    -- Optional: line change indicators
    changes = {
        add = ui.Style():fg("#4EC9B0"),         -- teal
        delete = ui.Style():fg("#F48771"),      -- soft red
        change = ui.Style():fg("#569CD6"),      -- soft blue
    },

    -- Optional: blame styling
    blame = {
        style = ui.Style():fg("#858585"):italic(),
        format = "    %author%, %age%",
    }
}

-- require("yatline"):setup({
-- 	-- section_separator = { open = "", close = "" },
-- 	-- inverse_separator = { open = "", close = "" },
-- 	-- part_separator = { open = "|", close = "|" },

-- 	style_a = {
-- 		fg = mocha_palette.mantle,
-- 		bg_mode = {
-- 			normal = mocha_palette.blue,
-- 			select = mocha_palette.mauve,
-- 			un_set = mocha_palette.red,
-- 		},
-- 	},
-- 	style_b = { bg = mocha_palette.surface0, fg = mocha_palette.text },
-- 	style_c = { bg = mocha_palette.base, fg = mocha_palette.text },

-- 	permissions_t_fg = mocha_palette.green,
-- 	permissions_r_fg = mocha_palette.yellow,
-- 	permissions_w_fg = mocha_palette.red,
-- 	permissions_x_fg = mocha_palette.sky,
-- 	permissions_s_fg = mocha_palette.lavender,

-- 	selected = { icon = "󰻭", fg = mocha_palette.yellow },
-- 	copied = { icon = "", fg = mocha_palette.green },
-- 	cut = { icon = "", fg = mocha_palette.red },

-- 	total = { icon = "", fg = mocha_palette.yellow },
-- 	succ = { icon = "", fg = mocha_palette.green },
-- 	fail = { icon = "", fg = mocha_palette.red },
-- 	found = { icon = "", fg = mocha_palette.blue },
-- 	processed = { icon = "", fg = mocha_palette.green },

-- 	tab_width = 20,
-- 	tab_use_inverse = true,

-- 	show_background = false,

-- 	display_header_line = true,
-- 	display_status_line = true,

-- 	header_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "line", custom = false, name = "tabs", params = { "left" } },
-- 			},
-- 			section_b = {
-- 				{ type = "coloreds", custom = false, name = "githead" },
-- 			},
-- 			section_c = {},
-- 		},
-- 		right = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "tab_path" },
-- 			},
-- 			section_b = {
-- 				{ type = "coloreds", custom = false, name = "task_workload" },
-- 			},
-- 			section_c = {
-- 				{ type = "coloreds", custom = false, name = "task_states" },
-- 			},
-- 		},
-- 	},

-- 	status_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "tab_mode" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "hovered_size" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_name" },
-- 				{ type = "coloreds", custom = false, name = "count" },
-- 			},
-- 		},
-- 		right = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "cursor_position" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "cursor_percentage" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
-- 				{ type = "coloreds", custom = false, name = "permissions" },
-- 			},
-- 		},
-- 	},
-- })


-- require("yatline-githead"):setup({
-- 	show_branch = true,
-- 	branch_prefix = "",
-- 	branch_symbol = "",
-- 	branch_borders = "",

-- 	commit_symbol = " ",

-- 	show_behind_ahead = true,
-- 	behind_symbol = " ",
-- 	ahead_symbol = " ",

-- 	show_stashes = true,
-- 	stashes_symbol = " ",

-- 	show_state = true,
-- 	show_state_prefix = true,
-- 	state_symbol = "󱅉",

-- 	show_staged = true,
-- 	staged_symbol = " ",

-- 	show_unstaged = true,
-- 	unstaged_symbol = " ",

-- 	show_untracked = true,
-- 	untracked_symbol = " ",

-- 	prefix_color = mocha_palette.pink,
-- 	branch_color = mocha_palette.pink,
-- 	commit_color = mocha_palette.mauve,
-- 	stashes_color = mocha_palette.teal,
-- 	state_color = mocha_palette.lavender,
-- 	staged_color = mocha_palette.green,
-- 	unstaged_color = mocha_palette.yellow,
-- 	untracked_color = mocha_palette.pink,
-- 	ahead_color = mocha_palette.green,
-- 	behind_color = mocha_palette.yellow,
-- })

--- @since 25.2.26

require("full-border"):setup({
	type = ui.Border.ROUNDED,
})
