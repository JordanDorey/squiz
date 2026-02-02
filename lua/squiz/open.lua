
local M = {}

function M.open(app)
    -- if already open do nothing
    if app.squiz_win and vim.api.nvim_win_is_valid(app.squiz_win) then
        vim.api.nvim_win_close(app.squiz_win, true)
        app.squiz_win = nil
        return
    end

    local current_win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(current_win) then return end

    local bufnr = vim.api.nvim_win_get_buf(current_win)
    if vim.bo[bufnr].buftype ~= "" then return end

    app.current_win = current_win
    require('squiz.window').create_squiz_win(app)
    require('squiz.keymaps').keymaps(app)
end

return M


