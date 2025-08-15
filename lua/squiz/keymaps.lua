local M = {}

local function open(app)
    local cursor = vim.api.nvim_win_get_cursor(app.window)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    if vim.api.nvim_win_is_valid(app.current_window) then
        vim.api.nvim_set_current_win(app.current_window)
    end

    if vim.api.nvim_win_is_valid(app.window) then
        vim.api.nvim_win_close(app.window, true)  -- close floating window
    end

    vim.api.nvim_win_set_buf(app.current_window, target_bufnr)
end

local function split(app)
    local cursor = vim.api.nvim_win_get_cursor(app.window)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    if vim.api.nvim_win_is_valid(app.current_window) then
        vim.api.nvim_set_current_win(app.current_window)
    end

    if vim.api.nvim_win_is_valid(app.window) then
        vim.api.nvim_win_close(app.window, true)  -- close floating window
    end

    vim.cmd("vsplit | buffer " .. target_bufnr)
end

local function delete(app)
    local cursor = vim.api.nvim_win_get_cursor(app.window)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    local target_file = string.sub(app.file_list[line], 4)

    -- check buffer is not modified
    local is_modified = vim.api.nvim_get_option_value('modified', { buf = target_bufnr })
    if is_modified then
        vim.notify("Buffer " .. target_file .. " has unsaved changes!", vim.log.levels.WARN)
        return
    end

    if vim.api.nvim_win_get_buf(app.current_window) == target_bufnr then
        vim.api.nvim_win_set_buf(app.current_window, 0)  -- 0 creates a new empty buffer
    end

    table.remove(app.buffer_list, line)
    table.remove(app.file_list, line)

    vim.api.nvim_set_option_value('modifiable', true, { buf = app.buffer })
    vim.cmd("normal! dd")
    vim.cmd("bd " .. target_bufnr)
    vim.api.nvim_buf_set_lines(app.buffer, 0, -1, false, app.file_list)
    vim.api.nvim_set_option_value('modifiable', false, { buf = app.buffer })
end

local function preview(app)
    local cursor = vim.api.nvim_win_get_cursor(app.window)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = target_bufnr })

    -- create a new buffer for preview
    vim.api.nvim_set_option_value('filetype', filetype, { buf = target_bufnr })
    vim.api.nvim_set_option_value('modifiable', false, { buf = target_bufnr })

    if app.preview_win and  vim.api.nvim_win_is_valid(app.preview_win) then
        vim.api.nvim_win_close(app.preview_win, true)
        return
    end

    local row, col = require('squiz.utils').positionWindow(app.opts.position, 120, 30)
    app.preview_win = vim.api.nvim_open_win(target_bufnr, true, {
        relative = "editor",
        width = 120,
        height = 30,
        row = row,
        col = col,
        border = "rounded",
    })

    vim.api.nvim_buf_attach(target_bufnr, false, {
        on_detach = function ()
            app.preview_win = nil
        end
    })

    vim.keymap.set('n', '<TAB>', function()
        if app.preview_win then
            vim.api.nvim_win_close(app.preview_win, true)
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })

    vim.keymap.set('n', '<CR>', function()
        if app.preview_win then
            local buf = vim.api.nvim_win_get_buf(app.preview_win)
            vim.api.nvim_win_set_buf(app.current_window, buf)
            vim.api.nvim_win_close(app.preview_win, true)
            vim.api.nvim_win_close(app.window, true)
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })

    vim.keymap.set('n', 'S', function()
        if app.preview_win then
            local buf = vim.api.nvim_win_get_buf(app.preview_win)
            vim.cmd("vsplit | buffer " .. buf)
            vim.api.nvim_win_close(app.preview_win, true)
            vim.api.nvim_win_close(app.window, true)
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })
end

function M.keymaps(app)
    vim.api.nvim_buf_set_keymap(app.buffer, "n", "<CR>", "", { callback = function() open(app) end })
    vim.api.nvim_buf_set_keymap(app.buffer, "n", "S", "", { callback = function() split(app) end })
    vim.api.nvim_buf_set_keymap(app.buffer, "n", "dd", "", { callback = function() delete(app) end })
    vim.api.nvim_buf_set_keymap(app.buffer, "n", "<TAB>", "", { callback = function() preview(app) end })
end

return M

