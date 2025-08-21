local M = {}


--- Populates list of buffer_list, file_list and icon_colours_list
---@param app table
function M.get_buffers(app)
    local buffer_list = {}
    local file_list = {}
    local icon_colour_list = {}

    local current_buf = vim.api.nvim_get_current_buf()
    local buffers = vim.api.nvim_list_bufs()

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            local filename = name ~= "" and vim.fn.fnamemodify(name, ":t") or ""
            local filetype = vim.filetype.match({ filename = filename })
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

            local icon, colour = app.devicons.get_icon(filename, filetype, { default = true })
            prefix = prefix .. icon .. " "

            if filename ~= ""  then
                table.insert(buffer_list, bufnr)
                table.insert(file_list, prefix .. filename)
                table.insert(icon_colour_list, colour)
            end
        end
    end

    app.buffer_list = buffer_list
    app.file_list = file_list
    app.icon_colour_list = icon_colour_list
end

return M
