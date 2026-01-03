# Squiz - buffer manager

This is a simple plugin to manage open buffers. The term "squiz" is a australian slang term used to quickly take a look i.e. "let me take a squiz". 

---

## Demonstartion
![Demo of squiz](https://github.com/JordanDorey/squiz/media/squiz.gif

---

## 🚀 Features

-   Open small window with the currently open buffers with "->" denoting the currently focused buffer
-   Open small window with the currently open buffers with "~" denoting that this buffer has been modified
-   "dd" in the squiz window will close the buffer under the cursor

---

## ⚡️ Requirements

-   Neovim version 0.8 or later.

---

## 📦 Installation

Use your favorite plugin manager.

### [Lazy]

```lua
{
    "JordanDorey/squiz",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("squiz").setup({
            width = 50,
            border = "rounded",
            position = "center",
        })
    end,
    keys = {
        { "<leader>sq", "<cmd>SquizOpen<cr>", desc = "Take a squiz" },
    },
}
```

### [Pack]

```lua
use {
  'JordanDorey/squiz',
  requires = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('squiz').setup({
        width = 50,
        border = "rounded",
        position = "center",
    })
  end
}
```

---

## ⌨️ Default Keybindings

These mappings are active only while the **Squiz** window is open. They allow you to manage your buffers quickly without leaving the floating interface.

| Key | Action |
| :--- | :--- |
| `<CR>` | **Focus**: Switch to the buffer under the cursor and close Squiz. |
| `<Tab>` | **Preview**: Open a preview of the buffer below the main window. |
| `dd` | **Delete**: Close (wipeout) the buffer under the cursor. |
| `S` | **Split**: Open the selected buffer in a new horizontal split. |
| `<Esc>` | **Exit**: Close the Squiz window and return to your code. |

---
