local M = {}

function M.get_buffers()
    local buffer_list = {}

    local file_list = {}
    local current_buf = vim.api.nvim_get_current_buf()
    local buffers = vim.api.nvim_list_bufs()

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            local filename = name ~= "" and vim.fn.fnamemodify(name, ":t") or ""
            local is_modified = vim.api.nvim_get_option_value('modified', { buf = bufnr })
            local prefix = ""

            if bufnr == current_buf then
                prefix = " -> "
            else
                prefix = "    "
            end

            if is_modified then
                prefix = prefix .. "~    "
            else
                prefix = prefix .. "     "
            end

            if filename ~= ""  then
                table.insert(buffer_list, bufnr)
                table.insert(file_list, prefix .. filename)
            end
        end
    end
    return buffer_list, file_list
end

return M
