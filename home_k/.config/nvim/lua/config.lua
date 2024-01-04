vim.g.loaded = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

if vim.fn.has("win32") then
    -- vim.opt.shell = "cmd"
    vim.opt.shell = vim.fn.executable("pwsh") > 0 and "pwsh" or "powershell"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
end

local nvimpid = vim.fn.getpid()

local function nvim_tree_on_attach(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.del("n", "s", { buffer = bufnr })
    vim.keymap.set("n", "s", api.node.open.vertical, opts("Split"))
    vim.keymap.set("n", "i", api.node.open.horizontal, opts("VSplit"))
    vim.keymap.set("n", "t", api.node.open.tab, opts("NewTab"))
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    vim.keymap.set("n", "<leader>n", api.tree.close, opts("Close"))
end

require("nvim-tree").setup({
    on_attach = nvim_tree_on_attach,
    view = {
        float = { enable = false, open_win_config = { border = "double" } },
    },
    filters = {
        git_ignored = false,
    },
})

vim.diagnostic.config({
    virtual_text = {
        -- source = true,
        format = function(diagnostic)
            if diagnostic.user_data and diagnostic.user_data.code then
                return string.format("%s %s", diagnostic.user_data.code, diagnostic.message)
            else
                return diagnostic.message
            end
        end,
    },
    signs = true,
    float = {
        -- header = "Diagnostics",
        source = true,
        -- border = "rounded",
    },
})

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "pyright", "vimls" } })

require("alpha").setup(require("alpha.themes.startify").config)

require("todo-comments").setup({
    highlight = { pattern = [[.*<(KEYWORDS)\s*]] },
    search = { pattern = [[\b(KEYWORDS)\b]] },
})

-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldclose:]]
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)

local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" ⋯   %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
end

require("ufo").setup({ close_fold_kinds = { "imports", "comment" }, fold_virt_text_handler = handler })

-- Set up nvim-cmp.
local cmp = require("cmp")
local lsp = require("lspconfig")
local lspkind = require("lspkind")
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local post_move = function(select_result, fallback)
    if not select_result then
        if vim.bo.buftype ~= "prompt" and has_words_before() then
            cmp.complete()
        else
            fallback()
        end
    end
end

local opts = { noremap = true, silent = true }
-- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    -- vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, bufopts)
    -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set("n", "<space>wl", function()
    --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, bufopts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<leader>rf", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
    end, bufopts)
end

cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        format = lspkind.cmp_format({
            -- mode = 'symbol', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        }),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        -- ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

        ["<PageDown>"] = function(fallback)
            local r
            for _ = 0, 4, 1 do
                r = cmp.select_next_item()
            end
            post_move(r, fallback)
        end,

        ["<PageUp>"] = function(fallback)
            local r
            for _ = 0, 4, 1 do
                r = cmp.select_prev_item()
            end
            post_move(r, fallback)
        end,

        ["<Tab>"] = function(fallback)
            post_move(cmp.select_next_item(), fallback)
        end,

        ["<S-Tab>"] = function(fallback)
            post_move(cmp.select_prev_item(), fallback)
        end,
    }),
    sources = {
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp" },
        { name = "ultisnips" },
        { name = "calc" },
        { name = "emoji" },
        { name = "path" },
        -- FIXME (k): <2022-10-24> pattern didn't work for now
        { name = "tmux", option = { keyword_pattern = [[\w\w\w\+]] }, trigger_characters = {} },
    },
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({ { name = "cmp_git" } }, { { name = "buffer" } }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- Set up lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

lsp.pyright.setup({ on_attach = on_attach, capabilities = capabilities })
-- lsp.pylsp.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.vimls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "vim-language-server", "--stdio" },
    filetypes = { "vim" },
    single_file_support = true,
    init_options = {
        diagnostic = { enable = true },
        indexes = {
            count = 3,
            gap = 100,
            projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
            runtimepath = true,
        },
        isNeovim = true,
        iskeyword = "@,48-57,_,192-255,-#",
        runtimepath = "",
        suggest = { fromRuntimepath = true, fromVimruntime = true },
        vimruntime = "",
    },
})

lsp.gopls.setup({
    cmd = { "gopls" },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
        },
    },
    init_options = { usePlaceholders = false },
})

-- lsp.lua_ls.setup({
--     settings = {
--         Lua = {
--             runtime = { version = "LuaJIT" },
--             diagnostics = { globals = { "vim" } },
--             workspace = { library = vim.api.nvim_get_runtime_file("", true) },
--             telemetry = { enable = false },
--         },
--     },
-- })
lsp.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
        },
    },
})

-- other lsp
-- lsp.phpactor.setup({
--     on_attach = on_attach,
--     capabilities = capabilities,
--     init_options = { ["language_server_phpstan.enabled"] = false, ["language_server_psalm.enabled"] = false },
-- })
lsp.omnisharp.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
        "/bin/OmniSharp",
        "--languageserver",
        "--hostPID",
        tostring(nvimpid),
    },
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
})
lsp.bashls.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.dockerls.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.yamlls.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.vls.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.marksman.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.taplo.setup({ on_attach = on_attach, capabilities = capabilities })
lsp.sqlls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "sql-language-server", "up", "--method", "stdio" },
})

require("nvim-autopairs").setup({
    disable_filetype = { "markdown" },
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Common Keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "K", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
        -- _, winid = vim.diagnostic.open_float()
        -- if not winid then
        --     vim.lsp.buf.hover()
        -- end
    end
end)

-- themes
local cololike = function(p)
    if vim.g.colors_name ~= nil and vim.g.colors_name:find(p, 1, true) == 1 then
        return true
    end
    return false
end

if cololike("github_") then
    require("github-theme").setup({
        dark_float = true,
        hide_inactive_statusline = false,
        sidebars = { "qf", "vista_kind", "terminal", "packer", "nerdtree", "vista" },
        function_style = "italic",
    })
end

-- more sensible goto
-- FIXME (k): <2022-10-20> definition else declaration
-- split and record the winid
-- close the winid if at old place
vim.keymap.set("n", "<leader>g", function()
    -- local origin_wid = vim.fn.win_getid()
    vim.cmd("split")
    vim.lsp.buf.definition({ reuse_win = false })
    -- local splited_wid = vim.api.nvim_get_current_win()
    -- vim.cmd(("echom 'origin %d splited %d'"):format(origin_wid, splited_wid))
    -- vim.lsp.buf_request_sync(0, 'textDocument/definition', {reuse_win = true})

    -- -- vim.lsp.buf.definition({reuse_win = true})
    -- vim.cmd(("echom 'current buffer %d'"):format(vim.api.nvim_get_current_buf()))
    -- vim.cmd(("echom 'current win %d'"):format(vim.api.nvim_get_current_win()))
    -- vim.cmd(("echom 'vim.fn: origin buffer %d splited buffer %d'"):format(
    --     vim.fn.winbufnr(origin_wid),
    --     vim.fn.winbufnr(splited_wid)
    -- ))
    -- vim.cmd(("echom 'nvim.api: origin buffer %d splited buffer %d'"):format(
    --     vim.api.nvim_win_get_buf(origin_wid),
    --     vim.api.nvim_win_get_buf(splited_wid)
    -- ))
    -- -- if vim.fn.winbufnr(origin_wid) == vim.fn.winbufnr(splited_wid) then
    -- --     vim.api.nvim_win_close(splited_wid, 0)
    -- -- end
end)

-- DAP
local dap = require("dap")
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
require("dap-python").setup("/usr/bin/python")
require("dap-go").setup({
    dap_configurations = {
        { type = "go", name = "Attach remote", mode = "remote", request = "attach" },
    },
    -- -- delve configurations
    -- delve = {
    --     -- time to wait for delve to initialize the debug session.
    --     -- default to 20 seconds
    --     initialize_timeout_sec = 20,
    --     -- a string that defines the port to start delve debugger.
    --     -- default to string "${port}" which instructs nvim-dap
    --     -- to start the process in a random available port
    --     port = "${port}",
    -- },
})
require("nvim-dap-virtual-text").setup({
    commented = true,
})
require("dapui").setup({
    icons = { expanded = "", collapsed = "", current_frame = "" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "o", "<2-LeftMouse>", "za" },
        open = "<CR>",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Use this to override mappings for specific elements
    element_mappings = {
        -- Example:
        -- stacks = {
        --   open = "<CR>",
        --   expand = "o",
        -- }
    },
    -- Expand lines larger than the window
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                "console",
                "breakpoints",
                "stacks",
                "watches",
                { id = "scopes", size = 0.30 },
            },
            size = 40, -- 40 columns
            position = "left",
        },
        -- {
        --     elements = { "repl", "console" },
        --     size = 0.25, -- 25% of total lines
        --     position = "bottom",
        -- },
    },
    controls = {
        -- Requires Neovim nightly (or 0.8 when released)
        enabled = true,
        -- Display controls in this element
        element = "console",
        icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
        },
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 2 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
    },
})

require("registers").setup({})

require("cmp").setup({
    enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
    end,
})

require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
    sources = {
        { name = "dap" },
    },
})

-- require("noice").setup({
--     lsp = {
--         -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--         override = {
--             ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--             ["vim.lsp.util.stylize_markdown"] = true,
--             ["cmp.entry.get_documentation"] = true,
--         },
--     },
--     -- you can enable a preset for easier configuration
--     presets = {
--         bottom_search = true, -- use a classic bottom cmdline for search
--         command_palette = true, -- position the cmdline and popupmenu together
--         long_message_to_split = true, -- long messages will be sent to a split
--         inc_rename = false, -- enables an input dialog for inc-rename.nvim
--         lsp_doc_border = false, -- add a border to hover docs and signature help
--     },
--     routes = {
--         {
--             view = "notify",
--             filter = { event = "msg_showmode" },
--         },
--     },
-- })

require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = { "NvimTree", "vista" },
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = function(str)
                    return str:sub(1, 1)
                end,
            },
        },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {
        lualine_a = {
            {
                "tabs",
                -- max_length = vim.o.columns / 2, -- Maximum width of tabs component.
                mode = 2, -- 0: Shows tab_nr 1: Shows tab_name 2: Shows tab_nr + tab_name
                -- tabs_color = {
                --     -- active = "lualine_{section}_normal",
                --     -- inactive = "lualine_{section}_inactive",
                -- },
                -- fmt = function(name, context)
                --     -- Show + if buffer is modified in tab
                --     local buflist = vim.fn.tabpagebuflist(context.tabnr)
                --     local winnr = vim.fn.tabpagewinnr(context.tabnr)
                --     local bufnr = buflist[winnr]
                --     local mod = vim.fn.getbufvar(bufnr, "&mod")
                --     return name .. (mod == 1 and " +" or "")
                -- end,
            },
        },
        -- lualine_a = {'buffers'},
        lualine_z = { "tabs" },
    },
    winbar = {},
    inactive_winbar = {},
    extensions = {},
})
