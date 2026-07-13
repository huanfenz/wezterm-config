-- 背景图片设置

local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

local options = {
    enabled = false,
    random = false,
    fixed_image = "03.jpg",
    interval_minutes = 5,
    image_dir = constants.CONFIG_DIR .. "\\images",
    image_hsb = {
        brightness = 0.08,
        hue = 1.0,
        saturation = 1.0,
    },
}

local image_pool = nil
local last_switch_time = 0
local last_image = nil
local current_index = 0

local function is_image_file(path)
    local lower = path:lower()
    return lower:match("%.png$")
        or lower:match("%.jpg$")
        or lower:match("%.jpeg$")
        or lower:match("%.webp$")
        or lower:match("%.gif$")
end

local function load_images()
    if image_pool and #image_pool > 0 then
        return image_pool
    end

    local ok, entries = pcall(wezterm.read_dir, options.image_dir)
    if not ok or not entries then
        wezterm.log_warn("Failed to read images directory: " .. options.image_dir)
        image_pool = nil
        return {}
    end

    local images = {}
    for _, entry in ipairs(entries) do
        if is_image_file(entry) then
            table.insert(images, entry)
        end
    end

    image_pool = images
    return image_pool
end

local function resolve_fixed_image()
    if not options.fixed_image or options.fixed_image == "" then
        return nil
    end

    return options.image_dir .. "\\" .. options.fixed_image
end

local function pick_random_image()
    local images = load_images()
    if #images == 0 then
        return last_image or resolve_fixed_image()
    end

    local index = math.random(#images)
    return full_path(images[index])
end

local function pick_image()
    if not options.enabled then
        return nil
    end

    if options.random then
        return pick_random_image()
    end

    return resolve_fixed_image()
end

local function apply_image(window, image)
    if not image then
        return
    end

    last_image = image

    local overrides = window:get_config_overrides() or {}
    overrides.window_background_image = image
    overrides.window_background_image_hsb = options.image_hsb
    window:set_config_overrides(overrides)
end

local function maybe_rotate(window)
    if not options.enabled then
        return
    end

    local interval_seconds = options.interval_minutes * 60
    local now = os.time()
    if now - last_switch_time < interval_seconds then
        return
    end

    last_switch_time = now
    apply_image(window, pick_image())
end

local function full_path(filename)
    if not filename then
        return nil
    end
    if filename:sub(1, #options.image_dir) == options.image_dir then
        return filename
    end
    return options.image_dir .. "\\" .. filename
end

local function pick_next_image()
    local images = load_images()
    if #images == 0 then
        return nil
    end
    current_index = current_index + 1
    if current_index > #images then
        current_index = 1
    end
    local entry = images[current_index]
    local filename = entry:match("([^\\/]+)$") or entry
    options.fixed_image = filename
    options.random = false
    return full_path(entry)
end

function M.toggle(window)
    options.enabled = not options.enabled
    if options.enabled then
        apply_image(window, full_path(pick_image()))
    else
        local overrides = window:get_config_overrides() or {}
        overrides.window_background_image = ""
        window:set_config_overrides(overrides)
    end
end

function M.next(window)
    if not options.enabled then
        options.enabled = true
    end
    last_switch_time = 0
    apply_image(window, pick_next_image())
end

function M.get_image_choices()
    local images = load_images()
    local choices = {}
    for _, entry in ipairs(images) do
        local filename = entry:match("([^\\/]+)$") or entry
        table.insert(choices, { label = filename })
    end
    return choices
end

function M.select_image(window, name)
    if not name then
        return
    end
    options.enabled = true
    options.fixed_image = name
    options.random = false
    last_switch_time = 0
    apply_image(window, full_path(name))
end

function M.apply(config)
    if not options.enabled then
        return
    end

    local initial = pick_image()
    if initial then
        config.window_background_image = full_path(initial)
        config.window_background_image_hsb = options.image_hsb
    end

    config.status_update_interval = options.interval_minutes * 60 * 1000

    wezterm.on("update-status", function(window, _pane)
        maybe_rotate(window)
    end)
end

return M
