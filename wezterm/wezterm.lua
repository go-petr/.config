-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ── Плагин resurrect (сохранение/восстановление сессии) ──
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- явная папка для файлов состояния
resurrect.state_manager.change_state_save_dir(wezterm.home_dir .. "/.local/share/wezterm/resurrect/")

-- автосейв воркспейса раз в минуту
resurrect.state_manager.periodic_save({ interval_seconds = 60 })

-- periodic_save НЕ пишет файл-указатель current_state, который нужен для
-- восстановления при старте. Дописываем его сами после каждого автосейва:
wezterm.on("resurrect.state_manager.periodic_save.finished", function()
  resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
end)

-- при запуске: восстановить прошлую сессию и открыть на весь экран
wezterm.on("gui-startup", function(cmd)
  -- восстановить сессию; ok = false, если восстанавливать нечего
  local ok = resurrect.state_manager.resurrect_on_gui_startup()
  if not ok then
    wezterm.mux.spawn_window(cmd or {})
  end
  -- дать окну создаться, затем перевести в нативный фуллскрин
  wezterm.time.call_after(0.2, function()
    local wins = wezterm.gui.gui_windows()
    if wins[1] then
      wins[1]:toggle_fullscreen()
    end
  end)
end)

-- ── Клавиши ─────────────────────────────────────────────
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- двойное Ctrl+B пробрасывает Ctrl+B в шелл
  { key = 'b', mods = 'LEADER|CTRL', action = wezterm.action.SendKey { key = 'b', mods = 'CTRL' } },

  -- сплиты
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- навигация по панелям
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },

  -- вкладки
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'e', mods = 'LEADER', action = wezterm.action.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, _, line)
        if line then window:active_tab():set_title(line) end
      end),
  }},

  -- resurrect: форс-сохранение текущего воркспейса
  { key = 'w', mods = 'LEADER', action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
  end)},

  -- resurrect: ручное восстановление из списка сохранений
  { key = 'r', mods = 'LEADER', action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        local type = string.match(id, "^([^/]+)")
        id = string.match(id, "([^/]+)$")
        id = string.match(id, "(.+)%..+$")
        local opts = { relative = true, restore_text = true, resize_window = false,
                       on_pane_restore = resurrect.tab_state.default_on_pane_restore }
        if type == "workspace" then
          resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(id, "workspace"), opts)
        elseif type == "window" then
          opts.window = pane:window()
          resurrect.window_state.restore_window(pane:window(), resurrect.state_manager.load_state(id, "window"), opts)
        elseif type == "tab" then
          resurrect.tab_state.restore_tab(pane:tab(), resurrect.state_manager.load_state(id, "tab"), opts)
        end
      end)
  end)},

  -- resurrect: удалить сохранение из списка (для чистки старых)
  { key = 'd', mods = 'LEADER', action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        resurrect.state_manager.delete_state(id)
      end, {
        title = "Delete State",
        description = "Выбери состояние для удаления: Enter = удалить, Esc = отмена, / = фильтр",
        fuzzy_description = "Поиск состояния для удаления: ",
        is_fuzzy = true,
      })
  end)},
}

-- ── Внешний вид ─────────────────────────────────────────
-- стартовый размер обычного окна (фуллскрин всё равно перекроет; держим близко к экрану 16")
config.initial_cols = 200
config.initial_rows = 55
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_decorations = "RESIZE"
config.color_scheme = 'ayu'

-- подгоняем цвета таб-бара под тему ayu (fancy-бар берёт цвета отдельно)
local ayu = wezterm.color.get_builtin_schemes()['ayu']
config.window_frame = {
  font = wezterm.font('MesloLGS Nerd Font Mono', { weight = 'Bold' }),
  font_size = 14,
  active_titlebar_bg = ayu.background,
  inactive_titlebar_bg = ayu.background,
}
config.colors = {
  tab_bar = {
    background = ayu.background,
    active_tab   = { bg_color = ayu.background, fg_color = '#FFB454', intensity = 'Bold' },
    inactive_tab = { bg_color = ayu.background, fg_color = '#5C6773' },
    inactive_tab_hover = { bg_color = ayu.background, fg_color = ayu.foreground },
    new_tab       = { bg_color = ayu.background, fg_color = '#5C6773' },
    new_tab_hover = { bg_color = ayu.background, fg_color = ayu.foreground },
  },
}
config.window_close_confirmation = 'NeverPrompt'
config.native_macos_fullscreen_mode = true

return config
