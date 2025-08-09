local buf_help = require("squiz.buffers")

local squiz = {}

local squiz_is_open = false
local win = nil
local buf = nil
local buffer_list = {}
local file_list = {}

function squiz.open_buffers_window()
    -- if already open do nothing
    if squiz_is_open then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)  -- close floating window
        end
        return
    end

    -- Get the list of listed buffers (open editable buffers)
    buffer_list, file_list = buf_help.get_buffers()

    if #buffer_list == 0 then
        return
    end

    local main_win = vim.api.nvim_get_current_win()

    -- Create a new scratch buffer for the floating window
    squiz_is_open = true
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        callback = function()
            squiz_is_open = false
        end,
    })

    -- Set the buffer lines to the list of buffer names
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_list)

    -- Window configuration: centered floating window
    local width = 80
    local height = math.min(#file_list, 15)  -- limit height for many buffers
    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = 0,
        col = 0,
        border = "single",
        anchor = "NW",
        title = " squiz ",
    }

    -- Open the window and return window handle if needed
    win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_set_option_value("cursorline", true, { win = win })

    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local line = cursor[1]
            local target_bufnr = buffer_list[line]
            if vim.api.nvim_win_is_valid(main_win) then
                vim.api.nvim_set_current_win(main_win)
            end

            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)  -- close floating window
            end

            vim.api.nvim_win_set_buf(main_win, target_bufnr)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "S", "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local line = cursor[1]
            local target_bufnr = buffer_list[line]
            if vim.api.nvim_win_is_valid(main_win) then
                vim.api.nvim_set_current_win(main_win)
            end

            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)  -- close floating window
            end

            vim.cmd("vsplit | buffer " .. target_bufnr)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "dd", "", {
        nowait = true,
        noremap = true,
        silent = false,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local line = cursor[1]
            local target_bufnr = buffer_list[line]
            local target_file = string.sub(file_list[line], 4)

            -- check buffer is not modified
            local is_modified = vim.api.nvim_get_option_value('modified', { buf = target_bufnr })
            if is_modified then
                vim.notify("Buffer " .. target_file .. " has unsaved changes!", vim.log.levels.WARN)
                return
            end

            if vim.api.nvim_win_get_buf(main_win) == target_bufnr then
                vim.api.nvim_win_set_buf(main_win, 0)  -- 0 creates a new empty buffer
            end

            table.remove(buffer_list, line)
            table.remove(file_list, line)

            vim.cmd("normal! dd")
            vim.cmd("bd " .. target_bufnr)
            print("Buffer number: ", target_bufnr)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_list)
        end
    })

end

return squiz
