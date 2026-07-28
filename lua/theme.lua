-- Single source of truth for every visual value used across
-- the terminal (Foot) and the shell (Bash prompt). Think of
-- this file like a set of CSS custom properties: change a
-- value here once, then regenerate every derived config with:
--
--     lua5.4 lua/generate.lua
--
-- Structure of this file:
--   1. Active theme selector
--   2. Palette definitions (pick or add your own)
--   3. Semantic color tokens (map palette -> meaning)
--   4. Font settings
--   5. Layout / window settings
--   6. Cursor settings
--   7. Prompt icons (Nerd Font glyphs)
--   8. Prompt segment toggles
--   9. Foot-specific extras (scrollback, URLs, selection)
--  10. Metadata

-- Choose which palette below is currently in use.
-- Valid values: "endeavouros_modern", "catppuccin_mocha",
--               "tokyo_night", "gruvbox_dark", "nord"
local ACTIVE_PALETTE = "endeavouros_modern"

-- Each palette uses the same key names so the generator can
-- treat them interchangeably. Add your own palette by copying
-- one of these blocks and giving it a new key.
local palettes = {
    endeavouros_modern = {
        background = "1a1b26",
        foreground = "c0caf5",
        cursor = "c0caf5",

        black   = "15161e",
        red     = "f7768e",
        green   = "9ece6a",
        yellow  = "e0af68",
        blue    = "7aa2f7",
        magenta = "bb9af7",
        cyan    = "7dcfff",
        white   = "a9b1d6",
    
        bright_black   = "414868",
        bright_red     = "f7768e",
        bright_green   = "9ece6a",
        bright_yellow  = "e0af68",
        bright_blue    = "7aa2f7",
        bright_magenta = "bb9af7",
        bright_cyan    = "7dcfff",
        bright_white   = "c0caf5",
    },

    catppuccin_mocha = {
        background = "1e1e2e",
        foreground = "cdd6f4",
        cursor     = "f5e0dc",
    
        black   = "45475a",
        red     = "f38ba8",
        green   = "a6e3a1",
        yellow  = "f9e2af",
        blue    = "89b4fa",
        magenta = "f5c2e7",
        cyan    = "94e2d5",
        white   = "bac2de",
    
        bright_black   = "585b70",
        bright_red     = "f38ba8",
        bright_green   = "a6e3a1",
        bright_yellow  = "f9e2af",
        bright_blue    = "89b4fa",
        bright_magenta = "f5c2e7",
        bright_cyan    = "94e2d5",
        bright_white   = "a6adc8",
    },
    
    tokyo_night = {
        background = "1a1b26",
        foreground = "a9b1d6",
        cursor     = "c0caf5",
    
        black   = "32344a",
        red     = "f7768e",
        green   = "9ece6a",
        yellow  = "e0af68",
        blue    = "7aa2f7",
        magenta = "ad8ee6",
        cyan    = "449dab",
        white   = "9699a8",
    
        bright_black   = "444b6a",
        bright_red     = "ff7a93",
        bright_green   = "b9f27c",
        bright_yellow  = "ff9e64",
        bright_blue    = "7da6ff",
        bright_magenta = "bb9af7",
        bright_cyan    = "0db9d7",
        bright_white   = "acb0d0",
    },
    
    gruvbox_dark = {
        background = "282828",
        foreground = "ebdbb2",
        cursor     = "ebdbb2",
    
        black   = "282828",
        red     = "cc241d",
        green   = "98971a",
        yellow  = "d79921",
        blue    = "458588",
        magenta = "b16286",
        cyan    = "689d6a",
        white   = "a89984",
    
        bright_black   = "928374",
        bright_red     = "fb4934",
        bright_green   = "b8bb26",
        bright_yellow  = "fabd2f",
        bright_blue    = "83a598",
        bright_magenta = "d3869b",
        bright_cyan    = "8ec07c",
        bright_white   = "ebdbb2",
    },
    
    nord = {
        background = "2e3440",
        foreground = "d8dee9",
        cursor     = "d8dee9",
    
        black   = "3b4252",
        red     = "bf616a",
        green   = "a3be8c",
        yellow  = "ebcb8b",
        blue    = "81a1c1",
        magenta = "b48ead",
        cyan    = "88c0d0",
        white   = "e5e9f0",
    
        bright_black   = "4c566a",
        bright_red     = "bf616a",
        bright_green   = "a3be8c",
        bright_yellow  = "ebcb8b",
        bright_blue    = "81a1c1",
        bright_magenta = "b48ead",
        bright_cyan    = "8fbcbb",
        bright_white   = "eceff4",
    },
}

-- Map raw palette colors to *meaning*. Generators and prompt
-- segments should reference these names, not raw hex values,
-- so swapping ACTIVE_PALETTE above re-themes everything.
local function build_semantic(palette)
    return {
        accent = palette.blue, 
        success = palette.green,
        warning = palette.yellow,
        danger = palette.red,
        info = palette.cyan,
        muted = palette.bright_black,
        surface = palette.background,
        on_surface = palette.foreground,
    }
end

-- Fonts
local font = {
  family = "JetBrainsMono Nerd Font",
  fallback = "DejaVu Sans Mono",  -- used if primary font is missing
  size = 11,
  ligatures = true,
  bold_is_bright = true,
}

-- Layout/Window
local layout = {
    pad_x = 14,
    pad_y = 14,
    opacity = 0.92, -- foot window alpha (0.0-1.0)
    border_radius = 10, -- applied via KWin, not foot
    initial_cols = 100,
    initial_rows = 30, 
}

-- Cursor
local cursor = {
    style = "beam", -- "block" | "beam" | "underline"
    blink = true,
    blink_rate_ms = 600,
}

-- Prompt Icons (nerd font)
local icons = {
    prompt_arrow = ">",
    git_branch = "⏰",
    git_dirty = "+",
    git_clean = "🧹",
    folder = "📁",
    home = "🏠",
    exit_ok = "⛓️‍💥",
    exit_fail = "❌",
    clock = "🕖",
}

-- Prompt Segments
-- Toggle which segments appear in the generated bash prompt,
-- and in what order (left to right).
local prompt_segments = {
    order = { "path", "git", "exit_code"},
    show_user_host = false, -- set true if this shell is used over SSH often
    show_time = false,
    multiline = true -- prompt arrow on its own line
}

-- Foot-Specific Extras
local foot_extras = {
    scrollback_lines = 10000,
    selection_target = "both", -- "primary" | "clipboard" | "both"
    url_launcher = "xdg-open",
    notify_on_bell = true,
    dpi_aware = true,
}

-- Metadata
local meta = {
    project = "EndeavourOS-Shell",
    version = "0.1.0",
    author = "BlobyCZ",
}

local active_colors = palettes[ACTIVE_PALETTE]
if not active_colors then
    error(("theme.lua unknown ACTIVE_PALLETE '%s'"):format(ACTIVE_PALETTE))
end

return {
    name = ACTIVE_PALETTE,
    palettes = palettes,
    colors = active_colors,
    semantic = build_semantic(active_colors),
    font = font,
    layout = layout,
    cursor = cursor,
    icons = icons,
    prompt_segments = prompt_segments,
    foot_extras = foot_extras,
    meta = meta,
}