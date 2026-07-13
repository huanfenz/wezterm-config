-- 指针

local M = {}

function M.apply(config)
    config.cursor_blink_ease_in = "Constant"
    config.cursor_blink_ease_out = "Constant"
    config.default_cursor_style = "SteadyBar"
    config.cursor_blink_rate = 650
    config.underline_thickness = "1pt"
end

return M
