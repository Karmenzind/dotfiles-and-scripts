#!/usr/bin/env lua
-- Github: https://github.com/Karmenzind/dotfiles-and-scripts

vim.g.loaded = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.completeopt = "menu,menuone,noselect"

local mopts = { noremap = true, silent = true }

local my_vimroot
if vim.fn.has("win32") == 1 then
    my_vimroot = vim.fn.glob("~") .. "\\vimfiles"
else
    my_vimroot = vim.fn.glob("~") .. "/.vim"
end
local plugged_dir = my_vimroot .. "/plugged"

local is_win = vim.loop.os_uname().version:match("Windows")
local nvimpid = vim.fn.getpid()

local function find_pybin()
    local preset = vim.fn.getenv("MY_VIM_PYTHON_PATH")
    if preset ~= vim.NIL and preset ~= "" then
        return preset
    end
    if is_win then
        for _, pat in ipairs({
            [[C:\Program Files\Python3*\python.exe]],
            [[~\AppData\Local\Programs\Python\Python*\python.exe]],
        }) do
            local expanded = vim.fn.glob(pat, false, true)
            if #expanded ~= 0 then
                return expanded[#expanded]
            end
        end
    else
        return "/usr/bin/python3"
    end
end
local py3bin = find_pybin()
if py3bin == nil or not vim.fn.executable(py3bin) then
    error("Failed to locate python executable")
end

-- Bootstrap lazy.nvim
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazypath = plugged_dir .. "/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

local my_vimrc_path
if is_win then
    vim.o.runtimepath = "~/vimfiles," .. vim.o.runtimepath .. ",~/vimfiles/after"
    vim.o.packpath = vim.o.runtimepath

    vim.g.python3_host_prog = py3bin

    -- shell
    vim.opt.shell = vim.fn.executable("pwsh") > 0 and "pwsh" or "powershell"
    vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""

    my_vimrc_path = "~/_vimrc"
else
    vim.o.runtimepath = "~/.vim," .. vim.o.runtimepath .. ",~/.vim/after"
    vim.o.packpath = vim.o.runtimepath
    vim.g.python3_host_prog = py3bin
    vim.g.ruby_host_prog = vim.fn.trim(vim.fn.system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'"))

    my_vimrc_path = "~/.vimrc"
end

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

local load_extra_colors
local enable_lsp_plugins
if vim.g.vscode then
    load_extra_colors = false
    enable_lsp_plugins = false
else
    load_extra_colors = true
    enable_lsp_plugins = true
end

-- Setup lazy.nvim
require("lazy").setup({
    root = plugged_dir,
    spec = {
        { "nvim-tree/nvim-tree.lua" },
        {
            "goolord/alpha-nvim",
            config = function()
                require("alpha").setup(require("alpha.themes.startify").config)
            end,
        },
        { "kyazdani42/nvim-web-devicons" },

        {
            "nvim-lualine/lualine.nvim",
            config = function()
                require("lualine").setup({
                    options = {
                        component_separators = { left = "", right = "" },
                        section_separators = { left = "", right = "" },
                        disabled_filetypes = { statusline = { "NvimTree", "vista" }, winbar = {} },
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
                    },
                })
            end,
        },
        {
            "nanozuki/tabby.nvim",
            config = function()
                require("tabby").setup()
            end,
        },
        { "windwp/nvim-autopairs" },

        -- Coding tools
        {
            "mfussenegger/nvim-lint",
            config = function()
                require("lint").linters_by_ft = { python = { "mypy" } }

                vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
                    callback = function()
                        require("lint").try_lint()
                    end,
                })
            end,
        },
        { "vim-autoformat/vim-autoformat" },
        { "tpope/vim-endwise" },
        { "tpope/vim-surround" },
        { "junegunn/vim-easy-align" },
        {
            "SirVer/ultisnips",
            lazy = false,
            event = "InsertEnter",
            config = function()
                vim.g.UltiSnipsExpandTrigger = "<c-j>"
                -- vim.g.UltiSnipsEditSplit = "context"
                -- vim.g.UltiSnipsUsePythonVersion = 3
                -- vim.g.UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = my_vimroot .. "/mysnippets"
                -- vim.g.UltiSnipsSnippetDirectories = { my_vimroot .. "/mysnippets", "UltiSnips" }
                -- vim.g.UltiSnipsEnableSnipMate = 1
                -- vim.g.UltiSnipsNoPythonWarning = 0
                -- vim.g.snips_author = "k"
                -- vim.g.snips_email = "valesail7@gmail.com"
                -- vim.g.snips_github = "https://github.com/Karmenzind/"
            end,
        },
        { "honza/vim-snippets" },
        { "Shougo/context_filetype.vim" },
        { "liuchengxu/vista.vim" },
        { "w0rp/ale" },
        { "mg979/vim-visual-multi", branch = "master" },

        -- Fuzzy Tools
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim", branch = "0.1.x", enabled = not vim.g.vscode },

        {
            "folke/todo-comments.nvim",
            branch = "main",
            config = function()
                require("todo-comments").setup({
                    highlight = { pattern = [[.*<(KEYWORDS)\s*]] },
                    search = { pattern = [[\b(KEYWORDS)\b]] },
                })
            end,
        },

        { "tversteeg/registers.nvim", branch = "main" },

        -- Java support
        { "nvim-java/lua-async-await", enable = enable_lsp_plugins },
        { "nvim-java/nvim-java-refactor", enable = enable_lsp_plugins },
        { "nvim-java/nvim-java-core", enable = enable_lsp_plugins },
        { "nvim-java/nvim-java-test", enable = enable_lsp_plugins },
        { "nvim-java/nvim-java-dap", enable = enable_lsp_plugins },
        { "nvim-java/nvim-java", enable = enable_lsp_plugins },
        { "JavaHello/spring-boot.nvim", enable = enable_lsp_plugins },

        -- UI and UX
        { "MunifTanjim/nui.nvim" },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                local tsconf = require("nvim-treesitter.configs")
                tsconf.setup({
                    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python" },
                    auto_install = true,
                })
            end,
        },
        {
            "kevinhwang91/nvim-ufo",
            lazy = false,
            dependencies = {
                "kevinhwang91/promise-async",
            },
            config = function()
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
                -- require("ufo").setup()
            end,
        },
        { "kyazdani42/nvim-web-devicons" },

        -- Colorschemes
        { "ishan9299/nvim-solarized-lua", enable = load_extra_colors },
        { "glepnir/zephyr-nvim", enable = load_extra_colors },
        { "Mofiqul/dracula.nvim", enable = load_extra_colors },
        { "rebelot/kanagawa.nvim", enable = load_extra_colors },
        { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ..., enable = load_extra_colors },
        { "daschw/leaf.nvim", enable = load_extra_colors },
        { "UtkarshVerma/molokai.nvim", branch = "main", enable = load_extra_colors },
        { "fcancelinha/nordern.nvim", enable = load_extra_colors },
        { "katawful/kat.nvim", tag = "3.1", enable = load_extra_colors },
        { "projekt0n/github-nvim-theme", enable = load_extra_colors },
        { "uloco/bluloco.nvim", enable = load_extra_colors },
        { "rktjmp/lush.nvim", enable = load_extra_colors },
        { "rockerBOO/boo-colorscheme-nvim", enable = load_extra_colors },
        { "kyazdani42/blue-moon", enable = load_extra_colors }, -- no airline theme
        { "folke/tokyonight.nvim", branch = "main", enable = load_extra_colors },
        { "EdenEast/nightfox.nvim", enable = load_extra_colors },
        { "gerardbm/vim-atomic", enable = load_extra_colors },
        -- { "icymind/NeoSolarized" ,enable=load_extra_colors},
        { "KKPMW/sacredforest-vim", enable = load_extra_colors },
        { "junegunn/seoul256.vim", enable = load_extra_colors },
        { "aktersnurra/no-clown-fiesta.nvim", enable = load_extra_colors },
        { "EdenEast/nightfox.nvim", enable = load_extra_colors },
        {
            "scottmckendry/cyberdream.nvim",
            priority = 1000,
            enable = load_extra_colors,
        },
        {
            "zenbones-theme/zenbones.nvim",
            priority = 1000,
            config = function()
                vim.g.zenbones_compat = 1
            end,
            enable = load_extra_colors,
        },
        -- { "flazz/vim-colorschemes" },

        -- LSP and Mason
        {
            "mason-org/mason.nvim",
            config = function()
                require("mason").setup({
                    PATH = "append",
                    registries = { "github:nvim-java/mason-registry", "github:mason-org/mason-registry" },
                    ui = { check_outdated_packages_on_open = false },
                    -- log_level = vim.log.levels.DEBUG,
                })
            end,
        },
        {
            "mason-org/mason-lspconfig.nvim",
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = { "lua_ls", "pyright", "vimls", "bashls", "marksman", "gopls" },
                    automatic_enable = false,
                })
            end,
        },
        { "neovim/nvim-lspconfig" },
        { "nvimdev/lspsaga.nvim", enable = enable_lsp_plugins },
        { "onsails/lspkind.nvim", enable = enable_lsp_plugins },
        { "kosayoda/nvim-lightbulb" },

        { "ray-x/lsp_signature.nvim", enable = enable_lsp_plugins },
        { "stevearc/aerial.nvim" },

        -- CMP
        { "hrsh7th/nvim-cmp", branch = "main" },
        { "hrsh7th/cmp-nvim-lsp-signature-help", branch = "main" },
        { "hrsh7th/cmp-nvim-lsp", branch = "main" },
        { "hrsh7th/cmp-buffer", branch = "main" },
        { "hrsh7th/cmp-path", branch = "main" },
        { "hrsh7th/cmp-calc", branch = "main" },
        { "hrsh7th/cmp-cmdline", branch = "main" },
        { "hrsh7th/cmp-emoji", branch = "main" },
        { "SergioRibera/cmp-dotenv" },
        {
            "andersevenrud/cmp-tmux",
            cond = function()
                return vim.env.TMUX ~= nil
            end,
        },
        { "quangnguyen30192/cmp-nvim-ultisnips" },

        -- Language-specific
        { "Hoffs/omnisharp-extended-lsp.nvim" },

        -- Debugging
        { "mfussenegger/nvim-dap" },
        { "mfussenegger/nvim-dap-python" },
        { "nvim-neotest/nvim-nio" },
        { "leoluz/nvim-dap-go" },
        { "rcarriga/nvim-dap-ui" },
        { "rcarriga/cmp-dap" },
        { "theHamsta/nvim-dap-virtual-text" },

        -- Version control
        { "tpope/vim-fugitive" },
        { "tiagofumo/vim-nerdtree-syntax-highlight" },
        { "t9md/vim-choosewin" },

        -- Search
        { "easymotion/vim-easymotion" },
        { "junegunn/vim-slash" },
        { "junegunn/fzf", build = "fzf#install", lazy = false },
        { "junegunn/fzf.vim", lazy = false },

        -- Python
        { "raimon49/requirements.txt.vim" },

        -- Documentation tools
        { "godlygeek/tabular" },
        { "mzlogin/vim-markdown-toc" },
        { "plasticboy/vim-markdown" },
        {
            "iamcco/markdown-preview.nvim",
            build = function()
                vim.fn["mkdp#util#install"]()
            end,
            ft = { "markdown", "vim-plug" },
        },
        { "nelstrom/vim-markdown-folding", ft = "markdown" },
        { "mklabs/vim-markdown-helpfile" },
        { "Traap/vim-helptags" },

        -- Enhancements
        { "SilverofLight/kd_translate.nvim" },
        { "dahu/vim-lotr" },
        -- { "karmenzind/vim-tmuxlike"},
        { "skywind3000/vim-quickui" },
        { "skywind3000/asyncrun.vim" },

        -- Syntax & fold
        { "posva/vim-vue" },
        { "cespare/vim-toml" },
        { "chr4/nginx.vim" },
        { "pangloss/vim-javascript" },
        { "mtdl9/vim-log-highlighting" },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true, frequency = 86400 },
})

vim.cmd("source " .. my_vimrc_path)
if vim.fn.filereadable(vim.g.extra_init_vim_path) > 0 then
    vim.cmd("source " .. vim.g.extra_init_vim_path)
end

local function term_esc()
    if vim.fn.match(vim.bo.filetype:lower(), [[\v^(fzf|telescope)]]) > -1 then
        vim.cmd("close")
    else
        vim.api.nvim_feedkeys("", "m", true)
    end
end

local function try_require(mod)
    local ok, imported = pcall(require, mod)
    if ok then
        return imported
    end
    vim.fn.EchoWarn("Failed to load " .. mod)
    return nil
end

local function lazy_esc(_)
    vim.keymap.set("t", "<Esc>", term_esc, mopts)
end

vim.api.nvim_create_augroup("fzf", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, { group = "fzf", pattern = "*", callback = lazy_esc })
if vim.g.fzf_layout["window"] == nil and vim.g.fzf_layout["tmux"] == nil then
    vim.api.nvim_create_autocmd({ "BufLeave" }, { group = "fzf", command = "set ls=2 smd ru" })
    vim.api.nvim_create_autocmd({ "FileType" }, { group = "fzf", pattern = "fzf", command = "setl ls=0 nosmd noru" })
end
-- require('fzf-lua').setup({'fzf-tmux'})

vim.cmd([[tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi']])

local kache = { tree_resized = false }
local function toggle_nvim_tree_resize()
    vim.cmd(kache.tree_resized and "NvimTreeResize -50" or "NvimTreeResize +50")
    kache.tree_resized = not kache.tree_resized
end

local function nvim_tree_on_attach(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.del("n", "<C-e>", { buffer = bufnr })
    vim.keymap.del("n", "s", { buffer = bufnr })
    vim.keymap.set("n", "s", api.node.open.vertical, opts("Split"))
    vim.keymap.set("n", "i", api.node.open.horizontal, opts("VSplit"))
    vim.keymap.set("n", "t", api.node.open.tab, opts("NewTab"))
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    vim.keymap.set("n", "<leader>n", api.tree.close, opts("Close"))
    vim.keymap.set("n", "A", toggle_nvim_tree_resize, { buffer = bufnr })
end

local function vscode_cmd(cmd)
    return function()
        return require("vscode").call(cmd)
    end
end

if vim.g.vscode then
    vim.keymap.set("n", "<leader>ff", vscode_cmd("workbench.action.quickOpen"), mopts)
    vim.keymap.set("n", "<leader>fa", vscode_cmd("workbench.action.findInFiles"), mopts)
    vim.keymap.set("n", "<leader>fr", vscode_cmd("workbench.action.findInFiles"), mopts)
    vim.keymap.set("n", "<leader>fg", vscode_cmd("workbench.action.findInFiles"), mopts)
    -- vim.keymap.set("n", "<leader>fb", require("vscode").action("workbench.action.quickOpen"), mopts)
    -- vim.keymap.set("n", "<leader>fh", require("vscode").action("workbench.action.quickOpen"), mopts)
elseif os.getenv("TMUX") == nil or vim.fn.executable("fzf") == 0 or os.getenv("NVIM_FUZZY_TOOL") == "telescope" then
    local ts = require("telescope")
    local tsa = require("telescope.actions")
    local tsbuiltin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", tsbuiltin.find_files, mopts)
    vim.keymap.set("n", "<leader>fg", tsbuiltin.live_grep, mopts)
    vim.keymap.set("n", "<leader>fb", tsbuiltin.buffers, mopts)
    vim.keymap.set("n", "<leader>fh", tsbuiltin.help_tags, mopts)
    ts.setup({
        defaults = {
            -- layout_config = { prompt_position = "top" },
            -- sorting_strategy = "ascending",
            border = true,
            mappings = {
                i = {
                    ["<esc>"] = tsa.close,
                    ["<C-j>"] = { tsa.move_selection_next, type = "action", opts = { nowait = true, silent = true } },
                    ["<C-k>"] = {
                        tsa.move_selection_previous,
                        type = "action",
                        opts = { nowait = true, silent = true },
                    },
                    ["<C-f>"] = { tsa.results_scrolling_down, type = "action", opts = { nowait = true, silent = true } },
                    ["<C-b>"] = { tsa.results_scrolling_up, type = "action", opts = { nowait = true, silent = true } },
                },
            },
            vimgrep_arguments = { "rg", "-u", "--color=never", "--no-heading", "--line-number", "--column" },
        },
        pickers = {
            find_files = { find_command = { "fd", "-t", "f", "-H", "-L", "-E", ".git" }, prompt_prefix = "📂 " },
            live_grep = { prompt_prefix = "🔍 " },
        },
    })
end

-- Structure / Files / Outline
if not vim.g.vscode then
    require("aerial").setup({
        -- autojump = true,
        show_guides = true,
    })
    vim.keymap.set("n", "<leader>A", "<cmd>AerialToggle!<CR>")

    require("nvim-tree").setup({
        hijack_netrw = true,
        hijack_directories = {
            enable = true,
            auto_open = true,
        },
        -- disable_netrw = true,
        hijack_unnamed_buffer_when_opening = true,
        -- update_focused_file = { enable = true, update_root = { enable = true, ignore_list = {} } },
        on_attach = nvim_tree_on_attach,
        view = { number = true, float = { enable = false, open_win_config = { border = "double" } } },
        filters = {
            git_ignored = false,
            custom = { [[\v(__pycache__|^\..*cache$)]] },
        },
    })
    vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", mopts)
    vim.keymap.set("n", "<leader>N", "<cmd>NvimTreeFindFile<CR>", mopts)
else
    vim.keymap.set("n", "<leader>n", vscode_cmd("workbench.action.toggleSidebarVisibility"), mopts)
    vim.keymap.set("n", "<leader>N", vscode_cmd("workbench.action.toggleSidebarVisibility"), mopts)
end

vim.diagnostic.config({
    jump = { float = true },
    virtual_text = {
        -- source = true,
        format = function(diagnostic)
            if diagnostic.user_data and diagnostic.user_data.code then
                return string.format("%s %s", diagnostic.user_data.code, diagnostic.message)
            end
            return diagnostic.message
        end,
    },
    signs = true,
    float = { source = true },
})

-- require("java").setup({ -- before lsp
--     jdk = { auto_install = false },
--     java_debug_adapter = {
--         enable = false,
--     },
--     notifications = {
--         dap = false,
--     },
-- })

-- Set up nvim-cmp.
local cmp = require("cmp")
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

vim.keymap.set("n", "]t", function()
    if vim.diagnostic.is_enabled() then
        vim.diagnostic.enable(false)
    else
        vim.diagnostic.enable()
    end
end, mopts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, mopts)

cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = { documentation = cmp.config.window.bordered() },
    formatting = { format = lspkind.cmp_format({ maxwidth = 50, ellipsis_char = "..." }) },
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
        { name = "tmux", option = { keyword_pattern = [[\w\w\w\+]] }, trigger_characters = {} },
        { name = "dotenv" },
    },
})

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({ { name = "cmp_git" }, { name = "emoji" } }, { { name = "buffer" } }),
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

-- LSP Configs
if not vim.g.vscode then
    local lsp_cap = require("cmp_nvim_lsp").default_capabilities()
    -- local lsp_cap = vim.lsp.protocol.make_client_capabilities()
    -- lsp_cap.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
    -- lsp_cap.textDocument.completion.completionItem.snippetSupport = true
    --
    local on_attach = function(client, bufnr)
        vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        -- vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, bufopts)
        -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        -- vim.keymap.set("n", "<space>wl", function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, bufopts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, bufopts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
        -- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", bufopts)
        -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", bufopts)
        vim.keymap.set("n", "<leader>rf", vim.lsp.buf.references, bufopts)
        -- vim.keymap.set("n", "<leader>rf", "<cmd>Lspsaga finder def+ref<CR>", bufopts)
        vim.keymap.set("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
        end, bufopts)

        -- require("lsp_signature").on_attach(client, bufnr) -- conflict with nvim_lsp_signature_help below
    end

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my.lsp", {}),
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            on_attach(client, args.buf)
        end,
    })

    vim.lsp.enable({
        "pyright",
        -- "basedpyright",
        "ruff",
        "gopls",
        "bashls",
        "dockerls",
        "yamlls",
        "vls",
        "marksman",
        "taplo",
        "html",
        "emmet_language_server",
        -- "vuels",
        "jdtls",
        "csharp_ls",
        "lua_ls",
        "sqlls",
        "ts_ls",
        "biome",
        "nginx_language_server",
        "docker_compose_language_service",
    })
    vim.lsp.config("*", { capabilities = lsp_cap })

    -- vim.lsp.config("ruff", { init_options = { configuration = "~/.config/ruff.toml" } })
    vim.lsp.config("vimls", {
        cmd = { "vim-language-server", "--stdio" },
        filetypes = { "vim" },
        single_file_support = true,
        init_options = {
            diagnostic = { enable = true },
            indexes = {
                count = 3,
                gap = 100,
                runtimepath = true,
                projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
            },
            isNeovim = true,
            iskeyword = "@,48-57,_,192-255,-#",
            runtimepath = "",
            suggest = { fromRuntimepath = true, fromVimruntime = true },
            vimruntime = "",
        },
    })

    vim.lsp.config("gopls", {
        cmd = { "gopls" },
        settings = {
            gopls = {
                experimentalPostfixCompletions = true,
                analyses = { unusedparams = true, shadow = true },
                staticcheck = true,
                gofumpt = true,
            },
        },
        init_options = { usePlaceholders = false },
    })

    vim.lsp.config("lua_ls", {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                    path ~= vim.fn.stdpath("config")
                    and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
                then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                    },
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                    },
                },
            })
        end,
        settings = {
            Lua = {},
        },
    })

    vim.lsp.config("omnisharp", {
        cmd = { "/bin/OmniSharp", "--languageserver", "--hostPID", tostring(nvimpid) },
        handlers = { ["textDocument/definition"] = require("omnisharp_extended").handler },
    })
    vim.lsp.config("sqlls", { cmd = { "sql-language-server", "up", "--method", "stdio" } })
    vim.lsp.config("ts_ls", {
        -- init_options = {
        --     plugins = {
        --         {
        --             name = "@vue/typescript-plugin",
        --             location = vim.fn.getenv("MY_VIM_TYPESCRIPT_PLUGIN_PATH")
        --                 or "/usr/local/lib/node_modules/@vue/typescript-plugin",
        --             languages = { "javascript", "typescript", "vue" },
        --         },
        --     },
        -- },
    })
    vim.lsp.config("nginx_language_server", { single_file_support = true })

    local ps_bundle_path = is_win and "~\\AppData\\Local\\nvim-data\\mason\\packages\\powershell-editor-services"
        or "~/.local/share/nvim*/mason/packages/powershell-editor-services"
    if vim.fn.glob(ps_bundle_path) ~= "" then
        vim.lsp.config("powershell_es", {
            bundle_path = ps_bundle_path,
            settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
        })
    else
        vim.fn.EchoWarn("Invalid ps_bundle_path")
    end

    require("lspsaga").setup({
        finder = { keys = { toggle_or_open = "<cr>" } },
        lightbulb = { virtual_text = true, sign = false },
    })
else
    vim.keymap.set("n", "<leader>rn", vscode_cmd("editor.action.rename"), mopts)
end

require("nvim-autopairs").setup({ disable_filetype = { "markdown" } })
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Common Keymaps
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, mopts)
vim.keymap.set("n", "K", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
        if vim.g.vscode then
            vim.lsp.buf.hover()
        else
            vim.fn.execute("Lspsaga hover_doc")
        end
    end
end, mopts)

-- more sensible goto
-- FIXME (k): <2022-10-20> definition else declaration
-- split and record the winid
-- close the winid if at old place
vim.keymap.set("n", "<leader>g", function()
    -- local origin_wid = vim.fn.win_getid()
    vim.cmd("split")
    vim.lsp.buf.definition({ reuse_win = false })
end, mopts)

-- DAP
if not vim.g.vscode then
    local dap = require("dap")
    vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
    dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
    require("dap-python").setup(py3bin)
    require("dap-go").setup({
        dap_configurations = { { type = "go", name = "Attach remote", mode = "remote", request = "attach" } },
    })
    require("nvim-dap-virtual-text").setup({ commented = true })
    require("dapui").setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
            expand = { "o", "<2-LeftMouse>", "za" },
            open = "<CR>",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
            {
                elements = { "console", "breakpoints", "stacks", "watches", { id = "scopes", size = 0.30 } },
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
            enabled = true,
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
        floating = { max_height = nil, max_width = nil, border = "single", mappings = { close = { "q", "<Esc>" } } },
        windows = { indent = 2 },
        render = { max_type_length = nil, max_value_lines = 100 },
    })

    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, mopts)
    vim.keymap.set("n", "<leader>dc", '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Condition: "))<cr>', mopts)
    vim.keymap.set("n", "<F5>", dap.continue, mopts)
    vim.keymap.set("n", "<F10>", dap.step_over, mopts)
    vim.keymap.set("n", "<F11>", dap.step_into, mopts)
    vim.keymap.set("n", "<F12>", dap.step_out, mopts)
    vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dapui'.float_element('repl')<cr>", mopts)
    vim.keymap.set("n", "<leader>du", "<cmd>lua require'dapui'.toggle({reset=true})<cr>", mopts)
    vim.keymap.set("n", "<leader>dl", dap.run_last, mopts)
end

if not vim.g.vscode then
    require("registers").setup({})
end

cmp.setup({
    enabled = function()
        return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or require("cmp_dap").is_dap_buffer()
    end,
})
cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, { sources = { { name = "dap" } } })

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

-- require("barbar").setup()

local ufo_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" ⋯  󰁂 %d "):format(endLnum - lnum)
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

require("ibl").setup()

require("ufo").setup({
    fold_virt_text_handler = ufo_handler,
    provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
    end,
    close_fold_kinds_for_ft = { default = { "imports", "comment" } },
})

-- FIXME (k): <2024-05-02 22:24>
-- require("ufo").setup({ close_fold_kinds_for_ft = { "imports", "comment" }, fold_virt_text_handler = ufo_handler })

local function rchoose(l)
    return l[math.random(1, #l)]
end

if vim.g.colors_name == nil and not vim.g.vscode then
    vim.g.boo_colorscheme_theme = rchoose({ "sunset_cloud", "radioactive_waste", "forest_stream", "crimson_moonlight" })
    vim.fn.RandomSetColo({
        "nightfox",
        "zephyr",
        "cyberdream",
        "dracula",
        "kanagawa",
        "zenbones",
        "leaf",
        "gruvbox",
        "molokai",
        "solarized",
        "blue-moon",
        -- "atomic",
        "boo",
        "nordern",
        -- "molokai",
        "kat.nvim",
        "kat.nwim",
        "bluloco",
        "tokyonight-night",
        "tokyonight-storm",
        "tokyonight-day",
        "tokyonight-moon",
        "seoul256",
        "github_dark_high_contrast",
        "github_light_high_contrast",
        "default",
        "nightfox",
        "no-clown-fiesta",
        -- installed from flazz's plugin
        -- "zenburn", "obsidian", "lyla", "madeofcode",
    })

    local cololike = function(p)
        return vim.g.colors_name ~= nil and vim.g.colors_name:find(p, 1, true) == 1
    end

    if cololike("github_") then
        require("github-theme").setup({
            options = {
                darken = {
                    sidebars = { "qf", "vista_kind", "terminal", "packer", "nerdtree", "vista" },
                    floats = false,
                },
                hide_nc_statusline = false,
                styles = { functions = "italic" },
            },
        })
    end
end

-- -- auto change root
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function(ctx)
--     local root = vim.fs.root(ctx.buf, { ".git", ".svn", "Makefile", "mvnw", "package.json" })
--     if root and root ~= "." and root ~= vim.fn.getcwd() then
--       ---@diagnostic disable-next-line: undefined-field
--       vim.cmd.cd(root)
--       vim.notify("Set CWD to " .. root)
--     end
--   end,
-- })

-- Other vscode specs
if vim.g.vscode then
    -- vim.g.clipboard = vim.g.vscode_clipboard
    vim.opt.clipboard:append("unnamedplus")
    pcall(vim.keymap.del, "n", "<leader>n")
    pcall(vim.keymap.del, "n", "<leader>N")

    vim.keymap.set("n", "<leader>vf", vscode_cmd("editor.action.formatDocument"), mopts)
end

-- vim.lsp.set_log_level("debug")
-- vim.opt.termguicolors = true

vim.keymap.set("n", "<leader>kd", ":TranslateNormal<CR>")
vim.keymap.set("v", "<leader>kd", ":TranslateVisual<CR>")
