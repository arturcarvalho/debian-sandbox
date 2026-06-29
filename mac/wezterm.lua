local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 16

-- Opacity
config.window_background_opacity = 0.95

-- Window chrome
config.window_decorations = 'RESIZE'  -- no title bar, keeps resize borders

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false

wezterm.on('format-tab-title', function(tab)
  return ' ⌘ ' .. (tab.tab_index + 1) .. ' '
end)

-- Gruvbox Dark Hard
config.colors = {
  foreground = '#ebdbb2',
  background = '#1d2021',
  cursor_bg = '#ebdbb2',
  cursor_fg = '#1d2021',
  ansi = {
    '#282828', '#cc241d', '#98971a', '#d79921',
    '#458588', '#b16286', '#689d6a', '#a89984',
  },
  brights = {
    '#928374', '#fb4934', '#b8bb26', '#fabd2f',
    '#83a598', '#d3869b', '#8ec07c', '#ebdbb2',
  },
  tab_bar = {
    background = '#1d2021',
    active_tab   = { bg_color = '#3c3836', fg_color = '#b8bb26' },
    inactive_tab = { bg_color = '#1d2021', fg_color = '#a89984' },
    inactive_tab_hover = { bg_color = '#3c3836', fg_color = '#ebdbb2' },
    new_tab      = { bg_color = '#1d2021', fg_color = '#a89984' },
  },
}

-- Splits
config.keys = {
  { key = 'd', mods = 'CMD',       action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
}

return config
