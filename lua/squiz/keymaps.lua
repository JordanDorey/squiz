local M = {}

local function close(app)
    if vim.api.nvim_win_is_valid(app.squiz_win) then
        vim.api.nvim_win_close(app.squiz_win, true)
        app.squiz_win = nil
    end
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
    vim.cmd("bd! " .. target_bufnr)
    require('squiz.window').update_squiz_win(app)
end

local function setup_autocmds(app)
    local group = vim.api.nvim_create_augroup("SquizPreview", { clear = true })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = app.squiz_buf, -- Only trigger inside the squiz list
        callback = function()
            local line = vim.api.nvim_win_get_cursor(0)[1]
            local target_bufnr = app.buffer_list[line]

            if target_bufnr and
                vim.api.nvim_win_is_valid(app.current_win) and
                vim.api.nvim_win_get_buf(app.current_win) ~= target_bufnr then

                vim.api.nvim_win_set_buf(app.current_win, target_bufnr)
            end
        end,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = app.squiz_buf, 
        callback = function()
            if app.squiz_win and vim.api.nvim_win_is_valid(app.squiz_win) then
                vim.api.nvim_win_close(app.squiz_win, true)
                app.squiz_win = nil
            end
        end,
    })
end


function M.keymaps(app)
    if not app.squiz_win or not vim.api.nvim_win_is_valid(app.squiz_win) then
        return
    end

    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "<CR>", "", { callback = function() close(app) end })
    -- vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "S", "", { callback = function() split(app) end })
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "dd", "", { callback = function() delete(app) end })
    -- vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "<TAB>", "", { callback = function() preview(app) end })
    vim.api.nvim_buf_set_keymap(app.squiz_buf, "n", "<ESC>", "", { callback = function() close(app) end })
    setup_autocmds(app)
end

return M

