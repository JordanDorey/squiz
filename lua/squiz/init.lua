local M = {}

M.app = {
    is_open = false,
    squiz_win = nil,
    squiz_buf = nil,
    current_win = nil,
    preview_win = nil,
    buffer_list = {},
    file_list = {},
    icon_colour_list = {},
    opts = nil,
    devicons = require('nvim-web-devicons')
}

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
