local M = {}

local function open(app)
    local cursor = vim.api.nvim_win_get_cursor(app.squiz_win)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    if vim.api.nvim_win_is_valid(app.current_win) then
        vim.api.nvim_set_current_win(app.current_win)
    end

    if vim.api.nvim_win_is_valid(app.squiz_win) then
        vim.api.nvim_win_close(app.squiz_win, true)
        app.squiz_win = nil
    end

    vim.api.nvim_win_set_buf(app.current_win, target_bufnr)
end

local function split(app)
    local cursor = vim.api.nvim_win_get_cursor(app.squiz_win)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    if vim.api.nvim_win_is_valid(app.current_win) then
        vim.api.nvim_set_current_win(app.current_win)
    end

    if vim.api.nvim_win_is_valid(app.squiz_win) then
        vim.api.nvim_win_close(app.squiz_win, true)
        app.squiz_win = nil
    end

    vim.cmd("vsplit | buffer " .. target_bufnr)
end

local function delete(app)
    local cursor = vim.api.nvim_win_get_cursor(app.squiz_win)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    local target_file = string.sub(app.line_list[line], 4)

    -- check buffer is not modified
    local is_modified = vim.api.nvim_get_option_value('modified', { buf = target_bufnr })
    if is_modified then
        vim.notify("Buffer " .. target_file .. " has unsaved changes!", vim.log.levels.WARN)
        return
    end

    if vim.api.nvim_win_get_buf(app.current_win) == target_bufnr then
        vim.api.nvim_win_set_buf(app.current_win, 0)
    end

    table.remove(app.buffer_list, line)
    table.remove(app.line_list, line)
    table.remove(app.file_name_list, line)
    table.remove(app.icon_colour_list, line)

    vim.api.nvim_set_option_value('modifiable', true, { buf = app.squiz_buf })
    vim.cmd("normal! dd")
    vim.cmd("bd " .. target_bufnr)
    require('squiz.window').update_squiz_win(app)
end

local function preview(app)
    local cursor = vim.api.nvim_win_get_cursor(app.squiz_win)
    local line = cursor[1]
    local target_bufnr = app.buffer_list[line]
    local file_name = app.file_name_list[line]
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = target_bufnr })

    if app.preview_win and vim.api.nvim_win_is_valid(app.preview_win) then
        vim.api.nvim_win_close(app.preview_win, true)
        vim.api.nvim_set_option_value('modifiable', true, { buf = target_bufnr })
        app.preview_win = nil
        return
    end

    vim.api.nvim_set_option_value('filetype', filetype, { buf = target_bufnr })
    vim.api.nvim_set_option_value('modifiable', false, { buf = target_bufnr })

    local row, col = require('squiz.window').positionWindow(app.opts.position, 120, 30)
    app.preview_win = vim.api.nvim_open_win(target_bufnr, true, {
        relative = "editor",
        width = 120,
        height = 30,
        row = row,
        col = col,
        border = "rounded",
        title = " " .. file_name .. " ",
    })

    vim.api.nvim_buf_attach(target_bufnr, false, {
        on_detach = function ()
            app.preview_win = nil
        end
    })

    vim.keymap.set('n', '<TAB>', function()
        if app.preview_win then
            local buf = vim.api.nvim_win_get_buf(app.preview_win)
            vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
            vim.api.nvim_win_close(app.preview_win, true)
            app.preview_win = nil
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })

    vim.keymap.set('n', '<CR>', function()
        if app.preview_win then
            local buf = vim.api.nvim_win_get_buf(app.preview_win)
            vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

            vim.api.nvim_win_set_buf(app.current_win, buf)
            vim.api.nvim_win_close(app.preview_win, true)
            vim.api.nvim_win_close(app.squiz_win, true)
            app.preview_win = nil
            app.squiz_win = nil
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })

    vim.keymap.set('n', 'S', function()
        if app.preview_win then
            local buf = vim.api.nvim_win_get_buf(app.preview_win)
            vim.cmd("vsplit | buffer " .. buf)
            vim.api.nvim_win_close(app.preview_win, true)
            vim.api.nvim_win_close(app.squiz_win, true)
            app.preview_win = nil
            app.squiz_win = nil
        end
    end, { buffer = target_bufnr, silent = true, noremap = true })
end

function M.keymaps(app)
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "<CR>", "", { callback = function() open(app) end })
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "S", "", { callback = function() split(app) end })
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "dd", "", { callback = function() delete(app) end })
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "<TAB>", "", { callback = function() preview(app) end })
end

return M

