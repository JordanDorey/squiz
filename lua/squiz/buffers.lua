local Buffers = {}


function Buffers.get_buffers()
    local buffer_list = {}
    local file_list = {}
    local current_buf = vim.api.nvim_get_current_buf()
    local buffers = vim.api.nvim_list_bufs()

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
    return buffer_list, file_list
end

return Buffers
