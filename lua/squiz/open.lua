
local M = {}

function M.open(app)
    -- if already open do nothing
    if app.is_open then
        if app.squiz_win and vim.api.nvim_win_is_valid(app.squiz_win) then
            vim.api.nvim_win_close(app.squiz_win, true)
        end
        if app.preview_win and vim.api.nvim_win_is_valid(app.preview_win) then
            vim.api.nvim_win_close(app.preview_win, true)
        end
        return
    end

    require('squiz.buffers').get_buffers(app)
    if #app.file_list == 0 then
        return
    end

    app.current_win = vim.api.nvim_get_current_win()

    app.is_open = true
    app.squiz_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = app.squiz_buf })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = app.squiz_buf,
        callback = function()
            app.is_open = false
        end,
    })

    -- Set the buffer lines to the list of buffer names
    vim.api.nvim_buf_set_lines(app.squiz_buf, 0, -1, false, app.file_list)
    vim.api.nvim_set_option_value('modifiable', false, { buf = app.squiz_buf })

    local ns_id = vim.api.nvim_create_namespace("squiz")
    for line_num = 0, #app.file_list - 1 do
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 0, { end_col = 3, hl_group = "Selected" })
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 4, { end_col = 5, hl_group = "Modified" })
        vim.api.nvim_buf_set_extmark(app.squiz_buf, ns_id, line_num, 9, { end_col = 12, hl_group = app.icon_colour_list[line_num+1] })
    end

    -- Window configuration: centered floating window
    local height = math.min(#app.file_list, 15)  -- limit height for many buffers
    local row, col = require('squiz.utils').positionWindow(app.opts.position, app.opts.width, height)
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

    -- Open the window and return window handle if needed
    app.squiz_win = vim.api.nvim_open_win(app.squiz_buf, true, opts)
    vim.api.nvim_set_option_value("cursorline", true, { win = app.squiz_win })

    require('squiz.keymaps').keymaps(app)
end

return M


