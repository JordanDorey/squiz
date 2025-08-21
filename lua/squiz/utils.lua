local M = {}

--- positions window
---@param position string
---@param win_w integer
---@param win_h integer
---@return integer
---@return integer
function M.positionWindow(position, win_w, win_h)
    local positions = {
        center = function () return (vim.o.lines - win_h) / 2, (vim.o.columns - win_w) / 2 end,
        NW = function () return 0, 0 end,
        N = function () return 0, (vim.o.columns - win_w) / 2 end,
        NE = function () return 0, vim.o.columns - win_w end,
        SE = function () return vim.o.lines - win_h, vim.o.columns - win_w end,
        S = function () return (vim.o.lines - win_h) / 2, 0 end,
        SW = function () return vim.o.lines - win_h, 0 end,
    }

    local fn = positions[position]
    if fn then
        return fn()
    end
    return 0, 0
end

return M
