local squiz = {}

local squiz_is_open = false
local win = nil

function squiz.open_buffers_window()
    -- if already open do nothing
    if squiz_is_open then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)  -- close floating window
        end
        return
    end

    -- Get the list of listed buffers (open editable buffers)
    local buffers = vim.api.nvim_list_bufs()
    local buffer_list = {}
    local file_list = {}
    local current_buf = vim.api.nvim_get_current_buf()

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            -- Trim full path to file name only (optional)
            local filename = name ~= "" and vim.fn.fnamemodify(name, ":t") or ""
            if bufnr == current_buf then
                filename = "-> " .. filename
            else
                filename = "   " .. filename
            end

            if filename ~= "   "  then
                table.insert(buffer_list, bufnr)
                table.insert(file_list, filename)
            end
        end
    end

    if #buffer_list == 0 then
        return
    end

    local main_win = vim.api.nvim_get_current_win()

    -- Create a new scratch buffer for the floating window
    squiz_is_open = true
    local buf = vim.api.nvim_create_buf(false, true)
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
        row = vim.o.lines - height,
        col = 0,
        border = "single",
        anchor = "SW",
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

    vim.api.nvim_buf_set_keymap(buf, "n", "s", "", {
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
end

return squiz
