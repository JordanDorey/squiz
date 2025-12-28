local M = {}

--- positions window
---@param position string
---@param win_w integer
---@param win_h integer
---@return integer
---@return integer
function M.positionWindow(position, win_w, win_h)
    local positions = {
        center = function () return (vim.o.lines - win_h) / 2, (vim.o.columns - win_w) / 2 end,
        NW = function () return 0, 0 end,
        N = function () return 0, (vim.o.columns - win_w) / 2 end,
        NE = function () return 0, vim.o.columns - win_w end,
        SE = function () return vim.o.lines - win_h, vim.o.columns - win_w end,
        S = function () return (vim.o.lines - win_h) / 2, 0 end,
        SW = function () return vim.o.lines - win_h, 0 end,
    }

    local fn = positions[position]
    if fn then
        return fn()
    end
    return 0, 0
end

function M.create_squiz_win(app)
    require('squiz.buffers').get_buffers(app)
    if #app.line_list == 0 then
        return
    end

    app.squiz_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = app.squiz_buf })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = app.squiz_buf,
        callback = function()
            app.squiz_buf = nil
        end,
    })

    M.update_squiz_win(app)
end

function M.update_squiz_win(app)
    vim.api.nvim_buf_set_lines(app.squiz_buf, 0, -1, false, app.line_list)
    vim.api.nvim_set_option_value('modifiable', false, { buf = app.squiz_buf })

    local ns_id = vim.api.nvim_create_namespace("squiz")
    for line_num = 0, #app.line_list - 1 do
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 0, { end_col = 3, hl_group = "Selected" })
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 4, { end_col = 5, hl_group = "Modified" })
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 9, { end_col = 12, hl_group = app.icon_colour_list[line_num+1] })
    end

    local height = math.min(#app.line_list, 15)
    if height == 0 then height = 1 end
    if app.squiz_win then
        vim.api.nvim_win_set_config(app.squiz_win, { height = height })
        return
    end

    local row, col = require('squiz.window').positionWindow(app.opts.position, app.opts.width, height)
    local opts = {
        style = "minimal",
        relative = "editor",
        width = app.opts.width,
        height = height,
        row = row,
        col = col,
        border = app.opts.border,
        anchor = "NW",
        title = "    M    File Name    ",
    }

    app.squiz_win = vim.api.nvim_open_win(app.squiz_buf, true, opts)
    vim.api.nvim_set_option_value("cursorline", true, { win = app.squiz_win })

    local current_main_buf = vim.api.nvim_win_get_buf(app.current_win)
    for i, bufnr in ipairs(app.buffer_list) do
        if bufnr == current_main_buf then
            vim.api.nvim_win_set_cursor(app.squiz_win, { i, 0 })
            break
        end
    end
end

return M
