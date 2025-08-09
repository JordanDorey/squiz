local M = {}

local app = {
    is_open = false,
    window = nil,
    buffer = nil,
    current_window = nil,
    buffer_list = {},
    file_list = {},
}

function M.open()
    require('squiz.open').open(app)
end

return M
