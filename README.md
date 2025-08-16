# Squiz - buffer manager


This is a simple plugin to manage open buffers. The term "squiz" is a australian slang term used to quickly take a look i.e. "take a squiz at this". 

---

## 🚀 Features

-   Open small window with the currently open buffers with "->" denoting the currently focused buffer
-   Open small window with the currently open buffers with "~" denoting that this buffer has been modified
-   Pressing tab will show a preview of the buffer under the cursor, within this window you are able to set this a your focused buffer by pressing enter
-   "dd" in the squiz window will close the buffer under the cursor
-   "S" in the squiz or preview window will open the buffer in a split view

---

## ⚡️ Requirements

-   Neovim version 0.8 or later.

---

## 📦 Installation

Use your favorite plugin manager.

### [Plugin Manager Name]

For example, using `lazy.nvim`:

```lua
-- lua/plugins/init.lua
return { 
    "JordanDorey/squiz", 
    config = function()
        require('squiz').setup({
            width = 50,
            border = "rounded",
            position = "center",
        })
    end
}
```


