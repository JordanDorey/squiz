local M = {}

M.app = {
    squiz_win = nil,
    squiz_buf = nil,
    current_win = nil,
    preview_win = nil,
    buffer_list = {},
    line_list = {},
    file_name_list = {},
    icon_colour_list = {},
    opts = nil,
    devicons = require('nvim-web-devicons')
}

-- removes the line from the tables
function M.app:remove_from_lists(line)
    table.remove(M.app.buffer_list, line)
    table.remove(M.app.line_list, line)
    table.remove(M.app.file_name_list, line)
    table.remove(M.app.icon_colour_list, line)
end

M.opts = {
    width = 50,
    border = "rounded",
    position = "center",
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})
    M.app.opts = M.opts
end

function M.open()
    require('squiz.open').open(M.app)
end

return M
