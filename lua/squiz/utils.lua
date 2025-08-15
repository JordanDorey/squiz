local M = {}

--- positions window
---@param position string
---@param win_w integer
---@param win_h integer
---@return integer
---@return integer
function M.positionWindow(position, win_w, win_h)
    if position == "NW" then
        return 0, 0
    end

    if position == "N" then
        return 0, (vim.o.columns - win_w) / 2
    end

    if position == "NE" then
        return 0, vim.o.columns - win_w
    end

    if position == "SW" then
        return vim.o.lines - win_h, 0
    end

    if position == "S" then
        return (vim.o.lines - win_h) / 2, 0
    end

    if position == "SE" then
        return vim.o.lines - win_h, vim.o.columns - win_w
    end

    if position == "center" then
        return (vim.o.lines - win_h) / 2, (vim.o.columns - win_w) / 2
    end
end

return M
