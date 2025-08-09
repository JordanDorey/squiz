
local M = {}

function M.open(app)
    -- if already open do nothing
    if app.is_open then
        if vim.api.nvim_win_is_valid(app.window) then
            vim.api.nvim_win_close(app.window, true)  -- close floating window
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

    -- Window configuration: centered floating window
    local width = 80
    local height = math.min(#app.file_list, 15)  -- limit height for many buffers
    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = 0,
        col = 0,
        border = "single",
        anchor = "NW",
        title = "    M    File Name    ",
    }

    -- Open the window and return window handle if needed
    app.window = vim.api.nvim_open_win(app.buffer, true, opts)
    vim.api.nvim_set_option_value("cursorline", true, { win = app.window })

    require('squiz.keymaps').keymaps(app)
end

return M


