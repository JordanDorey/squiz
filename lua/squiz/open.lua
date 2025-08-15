
local M = {}

function M.open(app)
    -- if already open do nothing
    if app.is_open then
        if app.window and vim.api.nvim_win_is_valid(app.window) then
            vim.api.nvim_win_close(app.window, true)  -- close floating window
        end
        if app.preview_win and vim.api.nvim_win_is_valid(app.preview_win) then
            vim.api.nvim_win_close(app.preview_win, true)  -- close floating window
        end

        return
    end

    -- Get the list of listed buffers (open editable buffers)
    app.buffer_list, app.file_list = require('squiz.buffers').get_buffers()
    if #app.file_list == 0 then
        return
    end

    app.current_window = vim.api.nvim_get_current_win()

    -- Create a new scratch buffer for the floating window
    app.is_open = true
    app.buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = app.buffer })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = app.buffer,
        callback = function()
            app.is_open = false
        end,
    })

    -- Set the buffer lines to the list of buffer names
    vim.api.nvim_buf_set_lines(app.buffer, 0, -1, false, app.file_list)
    vim.api.nvim_set_option_value('modifiable', false, { buf = app.buffer })

    for line_num = 0, #app.file_list - 1 do
        vim.api.nvim_buf_add_highlight(app.buffer, 0, "Selected", line_num, 0, 3)
        vim.api.nvim_buf_add_highlight(app.buffer, 0, "Modified", line_num, 4, 5)
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
    app.window = vim.api.nvim_open_win(app.buffer, true, opts)
    vim.api.nvim_set_option_value("cursorline", true, { win = app.window })

    require('squiz.keymaps').keymaps(app)
end

return M


