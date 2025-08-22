
local M = {}

function M.open(app)
    -- if already open do nothing
    if app.squiz_win and vim.api.nvim_win_is_valid(app.squiz_win) then
        vim.api.nvim_win_close(app.squiz_win, true)
        app.squiz_win = nil

        if app.preview_win and vim.api.nvim_win_is_valid(app.preview_win) then
            vim.api.nvim_win_close(app.preview_win, true)
            app.preview_win = nil
        end

        return
    end

    app.current_win = vim.api.nvim_get_current_win()
    require('squiz.window').create_squiz_win(app)
    require('squiz.keymaps').keymaps(app)
end

return M


