vim.api.nvim_create_user_command("SquizOpen", function()
    require("squiz").open_buffers_window()
end, {})

vim.api.nvim_set_keymap("n", "<leader>s", ":SquizOpen<CR>", { noremap = true, silent = true })
