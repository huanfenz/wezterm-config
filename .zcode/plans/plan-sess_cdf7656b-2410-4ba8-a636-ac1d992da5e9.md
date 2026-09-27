## 问题根因

WezTerm 搜索（Ctrl+Shift+F）时：
- **非当前匹配项**：用 `colors.copy_mode_inactive_highlight_*`，默认 Fuchsia 亮粉 —— 你觉得还可以，**保留不动**。
- **当前匹配项**：代码会把它自动设为选区，渲染层"Selected text overrides colors"分支让**选区色覆盖一切**，配置里默认的"当前项黄底"根本显示不出来。灰色的来源就是主题/WezTerm 默认的灰调选区色（`selection_bg`/`selection_fg`，本配置从未设置过）。

## 修改内容

**1. `config/colors.lua`** —— 在 `apply()` 开头（`catppuccin-frappe` 主题门槛判断**之前**，任何主题下都生效）新增：

```lua
-- 搜索高亮与选区颜色
-- 搜索模式的"当前匹配项"本质是一个选区，渲染时选区色覆盖单元格配色，
-- 所以必须设置 selection_* 才能改变当前项颜色（同时也会影响鼠标划选）
config.colors = config.colors or {}
config.colors.selection_bg = '#e5c890'  -- frappe 黄，黄底醒目
config.colors.selection_fg = 'none'     -- 文字保持原色（否则主题可能给浅色字，黄底上不清晰）
-- 复制模式下鼠标拖选的颜色，与选区保持一致
config.colors.copy_mode_active_highlight_bg = { Color = '#e5c890' }
config.colors.copy_mode_active_highlight_fg = { AnsiColor = 'Black' }
```

- 原有 `ansi`/`brights` 覆盖及 frappe 门槛逻辑保持不变（注意开头原来就有的 `config.colors = config.colors or {}` 保护需与新代码合并，避免重复/遗漏）
- 非当前项的粉色（默认 Fuchsia）不设置、不改动

**2. `AGENTS.md`** —— "注意"小节补一行：搜索当前匹配项按选区渲染，改颜色需设 `colors.selection_*`（在 `config/colors.lua`）。

## 验证

1. `wezterm --version` —— 确认 ≥ 20240127（`copy_mode_*_highlight` 字段需要的版本；`selection_*` 任何版本都支持，属兜底）
2. `wezterm start --no-auto-connect --always-new-process -- exit 0` —— 语法检查
3. 配置会热重载：按 Ctrl+Shift+F 搜索，当前项应为黄底+原文字色，其他项仍为粉色；鼠标划选同变为黄色

## 说明

- 若嫌鼠标选区纯黄太扎眼，可把 `selection_bg` 换成 `'rgba(229, 200, 144, 0.75)'` 半透明版，当前项清晰度略降但依然可辨
- 想换颜色只需改 `selection_bg`/`copy_mode_active_highlight_bg` 两处 hex