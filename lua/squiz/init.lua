local M = {}

M.app = {
    is_open = false,
    window = nil,
    buffer = nil,
    current_window = nil,
    buffer_list = {},
    file_list = {},
    preview_win = nil,
    opts = nil,
}

M.opts = {
    width = 50,
    border = "rounded"
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})
    M.app.opts = M.opts
end

function M.open()
    require('squiz.open').open(M.app)
end

return M
