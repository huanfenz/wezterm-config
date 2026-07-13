local wezterm = require("wezterm")

local M = {}

local function resolve_scheme(config)
    if not config or not config.color_scheme then
        return nil
    end

    local scheme_name = config.color_scheme
    if config.color_schemes and config.color_schemes[scheme_name] then
        return config.color_schemes[scheme_name]
    end

    local builtins = wezterm.get_builtin_color_schemes()
    if builtins and builtins[scheme_name] then
        return builtins[scheme_name]
    end

    return nil
end

local function pick_color(primary, fallback)
    if primary and primary ~= "" then
        return primary
    end
    return fallback
end

local function tab_bar_colors(config)
    local scheme = resolve_scheme(config)
    if not scheme then
        return nil
    end

    local background = pick_color(scheme.background, "#1b1d2b")
    local foreground = pick_color(scheme.foreground, "#c0c0c0")
    local inactive_fg = foreground
    if scheme.ansi and scheme.ansi[8] then
        inactive_fg = scheme.ansi[8]
    elseif scheme.brights and scheme.brights[1] then
        inactive_fg = scheme.brights[1]
    end
    local accent_fg = foreground
    if scheme.brights and scheme.brights[3] then
        accent_fg = scheme.brights[3]
    elseif scheme.ansi and scheme.ansi[3] then
        accent_fg = scheme.ansi[3]
    end
    local transparent = "rgba(0,0,0,0)"
    local hover_bg = "rgba(128,128,128,0.15)"

    return {
        background = transparent,
        active_tab = {
            bg_color = transparent,
            fg_color = accent_fg,
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = transparent,
            fg_color = inactive_fg,
        },
        inactive_tab_hover = {
            bg_color = hover_bg,
            fg_color = foreground,
        },
        new_tab = {
            bg_color = transparent,
            fg_color = inactive_fg,
        },
        new_tab_hover = {
            bg_color = hover_bg,
            fg_color = foreground,
        },
    }
end

function M.apply(config)
    config.enable_tab_bar = true
    config.tab_bar_at_bottom = false
    config.show_new_tab_button_in_tab_bar = true
    config.show_tab_index_in_tab_bar = false
    config.show_tabs_in_tab_bar = true
    config.switch_to_last_active_tab_when_closing_tab = true
    config.tab_max_width = 25
    config.use_fancy_tab_bar = true

    local colors = tab_bar_colors(config)
    if colors then
        config.colors = config.colors or {}
        config.colors.tab_bar = colors
    end
end

return M
