-- wezterm.lua
-- High-scale shell workflow: workspace templates + grouped keymaps + compact status.

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function basename(path)
  if not path or path == "" then
    return ""
  end
  return string.gsub(path, "(.*[/\\])(.*)", "%2")
end

local function uri_to_path(uri)
  if not uri then
    return nil
  end

  if type(uri) == "userdata" then
    return uri.file_path
  end

  local path = tostring(uri)
  path = path:gsub("^file://[^/]*", "")
  path = path:gsub("^file://", "")
  path = path:gsub("%%20", " ")
  return path
end

local function compact_cwd(uri)
  local path = uri_to_path(uri)
  if not path or path == "" then
    return ""
  end
  return basename(path)
end

local function compact_process(path)
  if not path or path == "" then
    return ""
  end
  return basename(path)
end

local function truncate_text(text, max_width)
  if not text or text == "" then
    return ""
  end
  if #text <= max_width then
    return text
  end
  if max_width <= 1 then
    return text
  end
  return string.sub(text, 1, max_width - 1) .. "…"
end

local function current_or_home_cwd(pane)
  local pane_cwd = pane and uri_to_path(pane:get_current_working_dir()) or nil
  if pane_cwd and pane_cwd ~= "" then
    return pane_cwd
  end
  return wezterm.home_dir
end

local function resolve_template_cwd(cwd, pane)
  if cwd and cwd ~= "$CURRENT_CWD" then
    return cwd
  end
  return current_or_home_cwd(pane)
end

local function make_shell_tabs(count, prefix)
  local tabs = {}
  for i = 1, count do
    tabs[i] = {
      title = string.format("%s-%02d", prefix, i),
      cwd = "$CURRENT_CWD",
    }
  end
  return tabs
end

local workspace_templates = {
  {
    id = "project-stack",
    label = "Project Stack",
    description = "Editor, git, server, tests, logs in current directory",
    workspace = "project",
    tabs = {
      { title = "editor", cwd = "$CURRENT_CWD" },
      { title = "git", cwd = "$CURRENT_CWD" },
      { title = "server", cwd = "$CURRENT_CWD" },
      { title = "tests", cwd = "$CURRENT_CWD" },
      { title = "logs", cwd = "$CURRENT_CWD" },
    },
  },
  {
    id = "ten-shells",
    label = "10 Shells",
    description = "Ten numbered shells in the current directory",
    workspace = "multishell",
    tabs = make_shell_tabs(10, "shell"),
  },
  {
    id = "triage",
    label = "Triage",
    description = "Inbox, prod, staging, db, observe, scratch",
    workspace = "triage",
    tabs = {
      { title = "inbox", cwd = "$CURRENT_CWD" },
      { title = "prod", cwd = "$CURRENT_CWD" },
      { title = "staging", cwd = "$CURRENT_CWD" },
      { title = "db", cwd = "$CURRENT_CWD" },
      { title = "observe", cwd = "$CURRENT_CWD" },
      { title = "scratch", cwd = "$CURRENT_CWD" },
    },
  },
}

local template_by_id = {}
for _, template in ipairs(workspace_templates) do
  template_by_id[template.id] = template
end

local function rename_tab_action()
  return act.PromptInputLine({
    description = "Rename tab title",
    action = wezterm.action_callback(function(window, _, line)
      if line and line ~= "" then
        window:active_tab():set_title(line)
      end
    end),
  })
end

local function prompt_tab_index_action()
  return act.PromptInputLine({
    description = "Activate tab number",
    action = wezterm.action_callback(function(window, pane, line)
      local index = tonumber(line or "")
      if not index or index < 1 then
        return
      end
      window:perform_action(act.ActivateTab(index - 1), pane)
    end),
  })
end

local function prompt_workspace_action()
  return act.PromptInputLine({
    description = "Switch to workspace (creates if missing)",
    action = wezterm.action_callback(function(window, pane, line)
      if not line or line == "" then
        return
      end
      window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
    end),
  })
end

local function spawn_workspace_template(window, pane, template_id)
  local template = template_by_id[template_id]
  if not template then
    wezterm.log_error("Unknown template id: " .. tostring(template_id))
    return
  end

  local target_workspace = template.workspace or template.id
  local first_spec = template.tabs[1] or { title = "shell", cwd = "$CURRENT_CWD" }

  local first_opts = {
    workspace = target_workspace,
    cwd = resolve_template_cwd(first_spec.cwd, pane),
  }
  if first_spec.args then
    first_opts.args = first_spec.args
  end

  local first_tab, _, mux_window = mux.spawn_window(first_opts)
  if first_spec.title and first_spec.title ~= "" then
    first_tab:set_title(first_spec.title)
  end

  for i = 2, #template.tabs do
    local spec = template.tabs[i]
    local tab_opts = {
      cwd = resolve_template_cwd(spec.cwd, pane),
    }
    if spec.args then
      tab_opts.args = spec.args
    end

    local tab = mux_window:spawn_tab(tab_opts)
    if spec.title and spec.title ~= "" then
      tab:set_title(spec.title)
    end
  end

  window:perform_action(act.SwitchToWorkspace({ name = target_workspace }), pane)
end

local function workspace_template_selector_action()
  local choices = {}
  for _, template in ipairs(workspace_templates) do
    local label = template.label
    if template.description and template.description ~= "" then
      label = string.format("%s - %s", template.label, template.description)
    end
    table.insert(choices, {
      id = template.id,
      label = label,
    })
  end

  return act.InputSelector({
    title = "Bootstrap Workspace Template",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(window, pane, id, _)
      if id then
        spawn_workspace_template(window, pane, id)
      end
    end),
  })
end

local function add_digit_jump_bindings(key_table)
  for i = 1, 9 do
    table.insert(key_table, { key = tostring(i), action = act.ActivateTab(i - 1) })
  end
  table.insert(key_table, { key = "0", action = act.ActivateTab(9) })
end

config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 14
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.default_workspace = "main"
config.adjust_window_size_when_changing_font_size = true
config.scrollback_lines = 12000
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 0,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 0,
}
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.75,
}

config.leader = {
  key = "a",
  mods = "CTRL",
  timeout_milliseconds = 1200,
}

local keys = {
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
  { key = "phys:Space", mods = "LEADER", action = act.ActivateCommandPalette },
  { key = "/", mods = "LEADER", action = act.ActivateCommandPalette },
  { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "f", mods = "LEADER", action = act.ToggleFullScreen },
  { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "g", mods = "LEADER", action = prompt_tab_index_action() },
  { key = "l", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }) },

  { key = "n", mods = "LEADER", action = act.ActivateKeyTable({ name = "nav_mode", one_shot = false }) },
  { key = "t", mods = "LEADER", action = act.ActivateKeyTable({ name = "tab_mode", one_shot = false }) },
  { key = "w", mods = "LEADER", action = act.ActivateKeyTable({ name = "workspace_mode", one_shot = false }) },
  { key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "pane_mode", one_shot = false }) },
  { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "session_mode", one_shot = false }) },

  { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },

  { key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
  { key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
}

for i = 1, 9 do
  table.insert(keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end
table.insert(keys, { key = "0", mods = "LEADER", action = act.ActivateTab(9) })

config.keys = keys

local nav_mode = {
  { key = "h", action = act.ActivateTabRelative(-1) },
  { key = "l", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", action = act.ActivateTabRelative(1) },
  { key = "j", action = act.ActivatePaneDirection("Down") },
  { key = "k", action = act.ActivatePaneDirection("Up") },
  { key = "t", action = act.ShowTabNavigator },
  { key = "w", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { key = "s", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
  { key = "p", action = act.ActivateLastTab },
  { key = "g", action = prompt_tab_index_action() },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}
add_digit_jump_bindings(nav_mode)

local tab_mode = {
  { key = "c", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "x", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "r", action = rename_tab_action() },
  { key = "n", action = act.ShowTabNavigator },
  { key = "p", action = act.ActivateLastTab },
  { key = "h", action = act.ActivateTabRelative(-1) },
  { key = "l", action = act.ActivateTabRelative(1) },
  { key = "H", action = act.MoveTabRelative(-1) },
  { key = "L", action = act.MoveTabRelative(1) },
  { key = "g", action = prompt_tab_index_action() },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}
add_digit_jump_bindings(tab_mode)

local workspace_mode = {
  { key = "l", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { key = "n", action = prompt_workspace_action() },
  { key = "m", action = act.SwitchToWorkspace({ name = "main" }) },
  { key = "b", action = workspace_template_selector_action() },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}

local pane_mode = {
  { key = "v", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "s", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "h", action = act.ActivatePaneDirection("Left") },
  { key = "j", action = act.ActivatePaneDirection("Down") },
  { key = "k", action = act.ActivatePaneDirection("Up") },
  { key = "l", action = act.ActivatePaneDirection("Right") },
  { key = "LeftArrow", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", action = act.ActivatePaneDirection("Right") },
  { key = "z", action = act.TogglePaneZoomState },
  { key = "x", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "o", action = act.RotatePanes("Clockwise") },
  { key = "r", action = act.ActivateKeyTable({ name = "resize_mode", one_shot = false }) },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}

local session_mode = {
  { key = "b", action = workspace_template_selector_action() },
  { key = "w", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { key = "t", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }) },
  { key = "n", action = prompt_workspace_action() },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}

local resize_mode = {
  { key = "h", action = act.AdjustPaneSize({ "Left", 2 }) },
  { key = "j", action = act.AdjustPaneSize({ "Down", 2 }) },
  { key = "k", action = act.AdjustPaneSize({ "Up", 2 }) },
  { key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
  { key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 2 }) },
  { key = "DownArrow", action = act.AdjustPaneSize({ "Down", 2 }) },
  { key = "UpArrow", action = act.AdjustPaneSize({ "Up", 2 }) },
  { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 2 }) },
  { key = "Escape", action = "PopKeyTable" },
  { key = "Enter", action = "PopKeyTable" },
}

config.key_tables = {
  nav_mode = nav_mode,
  tab_mode = tab_mode,
  workspace_mode = workspace_mode,
  pane_mode = pane_mode,
  session_mode = session_mode,
  resize_mode = resize_mode,
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.status_update_interval = 1000

local function resolve_tab_title(tab_info)
  if tab_info.tab_title and tab_info.tab_title ~= "" then
    return tab_info.tab_title
  end

  local pane = tab_info.active_pane
  if not pane then
    return "shell"
  end

  local proc = compact_process(pane.foreground_process_name)
  local cwd = compact_cwd(pane.current_working_dir)
  if proc ~= "" and proc ~= "zsh" and proc ~= "bash" and proc ~= "fish" then
    return proc
  end
  if cwd ~= "" then
    return cwd
  end
  if proc ~= "" then
    return proc
  end
  return "shell"
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local title = string.format("%d:%s", tab.tab_index + 1, resolve_tab_title(tab))
  if tab.active_pane and tab.active_pane.has_unseen_output then
    title = title .. " •"
  end

  local width = max_width or 32
  title = truncate_text(title, math.max(width - 2, 8))

  local edge = "#1a1b26"
  local bg = "#1f2335"
  local fg = "#7aa2f7"
  if hover then
    bg = "#292e42"
    fg = "#c0caf5"
  end
  if tab.is_active then
    bg = "#3b4261"
    fg = "#c0caf5"
  end

  return {
    { Background = { Color = edge } },
    { Foreground = { Color = bg } },
    { Text = wezterm.nerdfonts.pl_left_hard_divider },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = " " .. title .. " " },
    { Background = { Color = edge } },
    { Foreground = { Color = bg } },
    { Text = wezterm.nerdfonts.pl_right_hard_divider },
  }
end)

local function get_tab_count(window)
  local ok_window, mux_window = pcall(function()
    return window:mux_window()
  end)
  if not ok_window or not mux_window then
    return nil
  end

  local ok_tabs, tabs = pcall(function()
    return mux_window:tabs()
  end)
  if not ok_tabs or not tabs then
    return nil
  end
  return #tabs
end

wezterm.on("update-status", function(window, pane)
  local mode = window:active_workspace()
  local mode_color = "#f7768e"
  if window:active_key_table() then
    mode = string.upper(window:active_key_table())
    mode_color = "#7dcfff"
  end
  if window:leader_is_active() then
    mode = "LDR"
    mode_color = "#bb9af7"
  end

  local tab_count = get_tab_count(window)
  local tab_count_text = tab_count and (" " .. wezterm.nerdfonts.cod_browser .. " " .. tostring(tab_count)) or ""

  local cwd = compact_cwd(pane:get_current_working_dir())
  local cmd = compact_process(pane:get_foreground_process_name())
  local time = wezterm.strftime("%H:%M")

  if cwd == "" then
    cwd = "-"
  end
  if cmd == "" then
    cmd = "-"
  end

  window:set_left_status(wezterm.format({
    { Foreground = { Color = mode_color } },
    { Text = "  " .. wezterm.nerdfonts.oct_table .. " " .. mode },
    { Foreground = { Color = "#565f89" } },
    { Text = " |" },
    { Foreground = { Color = "#7aa2f7" } },
    { Text = tab_count_text .. " " },
  }))

  window:set_right_status(wezterm.format({
    { Text = wezterm.nerdfonts.md_folder .. " " .. truncate_text(cwd, 18) },
    { Foreground = { Color = "#565f89" } },
    { Text = " | " },
    { Foreground = { Color = "#e0af68" } },
    { Text = wezterm.nerdfonts.fa_code .. " " .. truncate_text(cmd, 18) },
    { Foreground = { Color = "#565f89" } },
    { Text = " | " },
    { Foreground = { Color = "#c0caf5" } },
    { Text = wezterm.nerdfonts.md_clock .. " " .. time .. "  " },
  }))
end)

return config
