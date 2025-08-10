vim.api.nvim_create_user_command("SquizOpen", function()

     require("squiz").open()
end, {})

vim.api.nvim_set_keymap("n", "<leader>s", ":SquizOpen<CR>", { noremap = true, silent = true })

vim.api.nvim_set_hl(0, "Selected", {
    fg = "#05D4FC",
    bold = true,
})
vim.api.nvim_set_hl(0, "Modified", {
    fg = "#FF9F0E",
    bold = true,
})
