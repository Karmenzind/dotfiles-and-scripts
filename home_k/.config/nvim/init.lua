#!/usr/bin/env lua
-- Github: https://github.com/Karmenzind/dotfiles-and-scripts

vim.g.loaded = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.completeopt = "menu,menuone,noselect"

-- --------------------------------------------
-- System
-- --------------------------------------------
-- local is_win = vim.loop.os_uname().version:match("Windows")
local is_win = vim.fn.has("win32") == 1
local is_macos = vim.fn.has("mac") == 1

if is_win and vim.env.TERM_PROGRAM == "rmux" then
    vim.opt.guicursor =
        "n-v-c-sm:block,i-ci-ve:ver25-blinkwait300-blinkon200-blinkoff150,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"
end

local my_mode = vim.fn.getenv("MY_VIM_MODE")

local mopts = { noremap = true, silent = true }

local my_lsps = {
    "pyright",
    -- "ty",
    "ruff",
    "gopls",
    "bashls",
    "dockerls",
    "yamlls",
    -- "vls",
    "marksman",
    -- "tombi",
    "html",
    "emmet_language_server",
    "jdtls",
    "csharp_ls",
    "lua_ls",
    "ts_ls",
    "biome",
    "nginx_language_server",
    "docker_compose_language_service",
    "svelte",
}

local cmp
local my_vimroot
local home
if vim.fn.has("win32") == 1 then
    home = os.getenv("USERPROFILE")
    my_vimroot = vim.fn.glob("~") .. "\\vimfiles"
else
    home = os.getenv("HOME")
    my_vimroot = vim.fn.glob("~") .. "/.vim"
end
local plugged_dir = my_vimroot .. "/plugged"
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
local my_vimrc_local_path
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
    my_vimrc_local_path = my_vimrc_path .. "_local"
else
    vim.o.runtimepath = "~/.vim," .. vim.o.runtimepath .. ",~/.vim/after"
    vim.o.packpath = vim.o.runtimepath
    vim.g.python3_host_prog = py3bin
    vim.g.ruby_host_prog = vim.fn.trim(vim.fn.system("find $HOME/.gem -regex '.*ruby/[^/]+/bin/neovim-ruby-host'"))

    my_vimrc_path = "~/.vimrc"
    my_vimrc_local_path = my_vimrc_path .. ".local"
end

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"
local load_extra_colors
local my_fuzzy_tool = nil
local load_lsp_plugins
if my_mode == "light" or vim.g.vscode then
    load_extra_colors = false
    load_lsp_plugins = false
    my_fuzzy_tool = "telescope"
else
    my_fuzzy_tool = os.getenv("NVIM_FUZZY_TOOL")
    if my_fuzzy_tool == nil then
        if is_win then
            my_fuzzy_tool = "telescope"
        elseif os.getenv("TMUX") ~= nil and vim.fn.executable("fzf") == 1 then
            my_fuzzy_tool = "fzf"
        else
            my_fuzzy_tool = "telescope"
        end
    end
    load_extra_colors = true
    load_lsp_plugins = true
end

-- Setup lazy.nvim
require("lazy").setup({
    root = plugged_dir,
    spec = {
        { "nvim-tree/nvim-tree.lua", cmd = { "NvimTreeToggle", "NvimTreeFindFile" } },
        {
            "goolord/alpha-nvim",
            config = function()
                require("alpha").setup(require("alpha.themes.startify").config)
            end,
        },

        {
            "nvim-lualine/lualine.nvim",
            cond = not vim.g.vscode,
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
            cond = not vim.g.vscode,
            config = function()
                require("tabby").setup()
            end,
        },
        { "windwp/nvim-autopairs" },

        -- AI Tools

        {
            "github/copilot.vim",
            config = function()
                vim.keymap.set("i", "<C-E>", 'copilot#Accept("\\<CR>")', {
                    expr = true,
                    replace_keycodes = false,
                })
                vim.g.copilot_no_tab_map = true
                vim.g.copilot_idle_delay = 500
                vim.g.copilot_trigger_on_idle = 1
            end,
        },
        -- { "zbirenbaum/copilot.lua",  dependencies = { "copilotlsp-nvim/copilot-lsp" } },

        {
            "olimorris/codecompanion.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
            },
            opts = {
                opts = { log_level = "DEBUG" },
                interactions = {
                    chat = { adapter = { name = "openai", model = "gpt-4o-mini" } },
                    inline = { adapter = { name = "openai", model = "gpt-4o-mini" } },
                    cmd = { adapter = { name = "openai", model = "gpt-4o-mini" } },
                },
            },
        },

        -- Coding tools
        {
            "mfussenegger/nvim-lint",
            event = { "BufReadPost", "BufWritePost" },
            cond = load_lsp_plugins,
            config = function()
                local lint = require("lint")
                lint.linters_by_ft = { python = { "mypy" } }

                -- lint.linters.mypy.args = {
                --     "--disable-error-code=import-untyped",
                --     -- "--show-error-codes",
                -- }

                vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
                    callback = function()
                        require("lint").try_lint()
                    end,
                })
            end,
        },
        { "tpope/vim-endwise" },
        { "tpope/vim-surround" },
        { "junegunn/vim-easy-align" },
        {
            "SirVer/ultisnips",
            lazy = false,
            event = "InsertEnter",
            config = function()
                vim.g.UltiSnipsExpandTrigger = "<c-j>"
            end,
        },
        { "honza/vim-snippets" },
        { "Shougo/context_filetype.vim" },
        { "liuchengxu/vista.vim" },
        -- { "w0rp/ale" },
        { "mg979/vim-visual-multi", branch = "master", cond = load_lsp_plugins },
        {
            "stevearc/conform.nvim",
            event = { "BufWritePre" },
            cmd = { "ConformInfo" },
            keys = {
                {
                    "<leader>af", -- 保持你 ALE 的快捷键习惯
                    function()
                        require("conform").format({ async = true, lsp_fallback = true })
                    end,
                    mode = "n",
                    desc = "Format buffer",
                },
            },
            opts = {
                -- 1. 对应 g:ale_fixers
                formatters_by_ft = {
                    ["*"] = { "trim_whitespace" },
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    go = { "goimports", "gofmt" },
                    javascript = { "biome" },
                    typescript = { "biome" },
                    lua = { "stylua" },
                    python = { "ruff_organize_imports", "ruff_format", "fix_surrounded_whitespace" },
                    sh = { "shfmt", "fix_leading_tabs" },
                    sql = { "pg_format" },
                    vue = { "eslint_d", "prettier" },
                    yaml = { "prettier" },
                },

                formatters = {
                    fix_surrounded_whitespace = {
                        format = function(self, ctx, lines, callback)
                            local new_lines = {}
                            for _, line in ipairs(lines) do
                                local fixed = line:gsub('^(%s*""")%s+(.+)%s+(""")', "%1%2%3")
                                table.insert(new_lines, fixed)
                            end
                            callback(nil, new_lines)
                        end,
                    },
                    -- 对应你的 FixLeadingTabs
                    fix_leading_tabs = {
                        format = function(self, ctx, lines, callback)
                            local spaces = string.rep(" ", vim.bo.tabstop)
                            local new_lines = {}
                            for _, line in ipairs(lines) do
                                local fixed = line:gsub("^\t+", function(match)
                                    return string.rep(spaces, #match)
                                end)
                                table.insert(new_lines, fixed)
                            end
                            callback(nil, new_lines)
                        end,
                    },

                    ["clang-format"] = {
                        prepend_args = {
                            "-style",
                            "{ BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 180, AllowShortBlocksOnASingleLine: Empty, AllowShortFunctionsOnASingleLine: Empty, BreakAfterJavaFieldAnnotations: true }",
                        },
                    },

                    biome = {
                        prepend_args = { "--line-width=120", "--indent-style=space" },
                    },

                    pg_format = {
                        prepend_args = { "-u", "1" },
                    },
                },
                -- format_on_save = { enabled = false, timeout_ms = 500, lsp_fallback = true },
            },
        },

        -- Fuzzy Tools
        { "nvim-lua/plenary.nvim" },
        {
            "nvim-telescope/telescope.nvim",
            version = "*",
            cmd = "Telescope",
            cond = not vim.g.vscode,
            dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },

            -- 1. Lazy-load on keys
            keys = function()
                local prefix = (my_fuzzy_tool == "telescope") and "<leader>f" or "<leader>t"
                return {
                    { prefix .. "f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
                    { prefix .. "g", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
                    { prefix .. "r", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
                    { prefix .. "b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
                    { prefix .. "h", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
                }
            end,

            -- 2. Declarative Configuration
            opts = function()
                local actions = require("telescope.actions")
                return {
                    defaults = {
                        sorting_strategy = "ascending",
                        layout_config = {
                            horizontal = {
                                prompt_position = "top",
                                preview_width = 0.55,
                            },
                            width = 0.87,
                            height = 0.80,
                        },
                        prompt_prefix = " 🔍 ",
                        selection_caret = "  ",
                        entry_prefix = "  ",
                        initial_mode = "insert",
                        border = true,
                        mappings = {
                            i = {
                                ["<esc>"] = actions.close,
                                ["<C-j>"] = actions.move_selection_next,
                                ["<C-k>"] = actions.move_selection_previous,
                                ["<C-f>"] = actions.results_scrolling_down,
                                ["<C-b>"] = actions.results_scrolling_up,
                            },
                        },
                        vimgrep_arguments = {
                            "rg",
                            "--color=never",
                            "--no-heading",
                            "--with-filename",
                            "--line-number",
                            "--column",
                            "--smart-case",
                            "--hidden",
                            "--glob",
                            "!.git/*",
                        },
                    },
                    pickers = {
                        find_files = {
                            find_command = {
                                "fd",
                                "--type",
                                "f",
                                "--hidden",
                                "--exclude",
                                ".git",
                                "--strip-cwd-prefix",
                            },
                        },
                    },
                    extensions = {
                        fzf = {
                            fuzzy = true,
                            override_generic_sorter = true,
                            override_file_sorter = true,
                            case_mode = "smart_case",
                        },
                    },
                }
            end,
            config = function(_, opts)
                local telescope = require("telescope")
                telescope.setup(opts)
                -- 2026 实践：显式加载已安装的扩展
                pcall(telescope.load_extension, "fzf")
            end,
        },

        -- {
        --     "folke/todo-comments.nvim",
        --     branch = "main",
        --     config = function()
        --         require("todo-comments").setup({
        --             highlight = { pattern = [[.*<(KEYWORDS)\s*]] },
        --             search = { pattern = [[\b(KEYWORDS)\b]] },
        --         })
        --     end,
        -- },

        -- { "tversteeg/registers.nvim", branch = "main" },

        -- Java support
        -- { "nvim-java/lua-async-await", cond = load_lsp_plugins },
        -- { "nvim-java/nvim-java-refactor", cond = load_lsp_plugins },
        -- { "nvim-java/nvim-java-core", cond = load_lsp_plugins },
        -- { "nvim-java/nvim-java-test", cond = load_lsp_plugins },
        -- { "nvim-java/nvim-java-dap", cond = load_lsp_plugins },
        -- { "nvim-java/nvim-java", cond = load_lsp_plugins },
        -- { "JavaHello/spring-boot.nvim", cond = load_lsp_plugins },
        -- {
        --     "mfussenegger/nvim-jdtls",
        --     dependencies = { "neovim/nvim-lspconfig" },
        --     config = function()
        --         local config = {
        --             cmd = { vim.fn.getenv("MY_JDTLS_PATH") },
        --             root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
        --         }
        --         require("jdtls").start_or_attach(config)
        --     end,
        -- },

        -- UI and UX
        { "MunifTanjim/nui.nvim" },
        {
            "nvim-treesitter/nvim-treesitter",
            branch = "main",
            build = ":TSUpdate",
            config = function()
                local ok, tsconf = pcall(require, "nvim-treesitter.configs")
                if not ok then
                    vim.notify("nvim-treesitter not loaded", vim.log.levels.WARN)
                    return
                end

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

                require("ufo").setup({
                    fold_virt_text_handler = ufo_handler,
                    provider_selector = function(bufnr, filetype, buftype)
                        return { "treesitter", "indent" }
                    end,
                    close_fold_kinds_for_ft = { default = { "imports", "comment" } },
                })
            end,
            cond = my_mode ~= "light",
        },
        { "kyazdani42/nvim-web-devicons" },

        -- Colorschemes
        { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ..., cond = load_extra_colors },
        { "ishan9299/nvim-solarized-lua", cond = load_extra_colors },
        { "glepnir/zephyr-nvim", cond = load_extra_colors },
        { "Mofiqul/dracula.nvim", cond = load_extra_colors },
        { "rebelot/kanagawa.nvim", cond = load_extra_colors },
        { "daschw/leaf.nvim", cond = load_extra_colors },
        { "UtkarshVerma/molokai.nvim", branch = "main", cond = load_extra_colors },
        { "fcancelinha/nordern.nvim", cond = load_extra_colors },
        { "katawful/kat.nvim", tag = "3.1", cond = load_extra_colors },
        { "projekt0n/github-nvim-theme", cond = load_extra_colors },
        { "uloco/bluloco.nvim", cond = load_extra_colors },
        { "rktjmp/lush.nvim", cond = load_extra_colors },
        { "rockerBOO/boo-colorscheme-nvim", cond = load_extra_colors },
        { "kyazdani42/blue-moon", cond = load_extra_colors }, -- no airline theme
        { "folke/tokyonight.nvim", branch = "main", cond = load_extra_colors },
        { "EdenEast/nightfox.nvim", cond = load_extra_colors },
        { "gerardbm/vim-atomic", cond = load_extra_colors },
        -- { "icymind/NeoSolarized" ,enable=load_extra_colors},
        { "KKPMW/sacredforest-vim", cond = load_extra_colors },
        { "junegunn/seoul256.vim", cond = load_extra_colors },
        { "aktersnurra/no-clown-fiesta.nvim", cond = load_extra_colors },
        {
            "scottmckendry/cyberdream.nvim",
            priority = 1000,
            cond = load_extra_colors,
        },
        {
            "zenbones-theme/zenbones.nvim",
            priority = 1000,
            config = function()
                vim.g.zenbones_compat = 1
            end,
            cond = load_extra_colors,
        },
        -- { "flazz/vim-colorschemes" },

        -- LSP and Mason
        {
            "mason-org/mason.nvim",
            cond = load_lsp_plugins,
            config = function()
                require("mason").setup({
                    PATH = "append",
                    -- registries = { "github:nvim-java/mason-registry", "github:mason-org/mason-registry" },
                    registries = { "github:mason-org/mason-registry" },
                    ui = { check_outdated_packages_on_open = false },
                    -- log_level = vim.log.levels.DEBUG,
                })
            end,
        },
        {
            "mason-org/mason-lspconfig.nvim",
            cond = load_lsp_plugins,
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = my_lsps,
                    automatic_enable = false,
                })
            end,
        },
        { "neovim/nvim-lspconfig", cond = load_lsp_plugins },
        { "nvimdev/lspsaga.nvim", cond = load_lsp_plugins },
        { "onsails/lspkind.nvim", cond = load_lsp_plugins },
        -- { "kosayoda/nvim-lightbulb", cond = load_lsp_plugins },

        -- { "ray-x/lsp_signature.nvim", cond = load_lsp_plugins },
        { "stevearc/aerial.nvim" },

        -- CMP
        { "hrsh7th/nvim-cmp", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-nvim-lsp-signature-help", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-nvim-lsp", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-buffer", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-path", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-calc", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-cmdline", branch = "main", cond = load_lsp_plugins },
        { "hrsh7th/cmp-emoji", branch = "main", cond = load_lsp_plugins },
        { "SergioRibera/cmp-dotenv", cond = load_lsp_plugins },
        { "andersevenrud/cmp-tmux", cond = load_lsp_plugins and vim.env.TMUX ~= nil },
        { "quangnguyen30192/cmp-nvim-ultisnips", cond = load_lsp_plugins },

        -- Language-specific
        { "Hoffs/omnisharp-extended-lsp.nvim", cond = load_lsp_plugins },

        -- Debugging
        { "mfussenegger/nvim-dap", cond = load_lsp_plugins },
        -- { "mfussenegger/nvim-dap-python", cond = load_lsp_plugins },
        { "nvim-neotest/nvim-nio", cond = load_lsp_plugins },
        { "leoluz/nvim-dap-go", cond = load_lsp_plugins },
        { "rcarriga/nvim-dap-ui", cond = load_lsp_plugins },
        { "rcarriga/cmp-dap", cond = load_lsp_plugins },
        { "theHamsta/nvim-dap-virtual-text", cond = load_lsp_plugins },

        -- Version control
        { "tpope/vim-fugitive" },
        { "t9md/vim-choosewin" },

        -- Search
        { "easymotion/vim-easymotion" },
        { "junegunn/vim-slash" },
        { "junegunn/fzf", build = "fzf#install", lazy = false, cond = my_fuzzy_tool == "fzf" },
        { "junegunn/fzf.vim", lazy = false, cond = my_fuzzy_tool == "fzf" },

        -- Python
        -- { "raimon49/requirements.txt.vim" },

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
        { "SilverofLight/kd_translate.nvim", cond = my_mode ~= "light" },
        { "dahu/vim-lotr" },
        {
            "karmenzind/vim-tmuxlike",
            config = function()
                require("tmuxlike").setup({
                    prefix = "<C-\\>",
                    chooser = {
                        font = "pagga",
                    },
                })
            end,
        },
        -- {
        --     "karmenzind/vim-tmuxlike",
        --     dir = vim.fn.isdirectory(vim.fn.expand("$HOME/Localworks/vim-tmuxlike")) == 1 and vim.fn.expand("$HOME/Localworks/vim-tmuxlike")
        --         or nil,
        -- },
        { "skywind3000/vim-quickui", cond = my_mode ~= "light" },
        { "skywind3000/asyncrun.vim", cond = my_mode ~= "light" },

        -- Syntax & fold
        -- { "posva/vim-vue", cond = my_mode ~= "light" },
        -- { "cespare/vim-toml" },
        { "chr4/nginx.vim" },
        { "pangloss/vim-javascript" },
        { "mtdl9/vim-log-highlighting" },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            cond = my_mode ~= "light",
            config = function()
                require("ibl").setup()
            end,
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true, frequency = my_fuzzy_tool == "light" and 86400 * 7 or 86400 * 3 },
})

vim.cmd(string.format("let g:my_fuzzy_tool = '%s'", my_fuzzy_tool))

-- ==============================================================
-- Ported from .vimrc (native replacement for `source .vimrc`)
-- ==============================================================

-- /* HHKB backspace remap */
local function is_hhkb()
    if is_win then
        return false
    end
    local out = vim.fn.system("grep 'HHKB' /proc/bus/input/devices")
    return vim.v.shell_error == 0 and out ~= nil and out ~= ""
end

if is_hhkb() then
    -- vimrc had `noremap <BS> <NOP>` immediately followed by `map <BS> <Leader>`
    -- for the same modes (n/v/o); the second silently wins.
    vim.keymap.set({ "n", "v", "o" }, "<BS>", "<Leader>")
end

-- /* cabbrevs */
local function no_search_cabbrev(abbr, expanded)
    -- long-bracket string avoids Lua reinterpreting \v \s \1 \r -- they need
    -- to reach vimscript's own double-quoted string escaping untouched
    vim.cmd(string.format([[cabbrev <expr> %s (getcmdtype() == ':') ? "%s" : "%s"]], abbr, expanded, abbr))
end

no_search_cabbrev("w!!", "w !sudo tee %")
no_search_cabbrev("GI", "GoImport")
no_search_cabbrev("th", "tab<SPACE>help")
no_search_cabbrev("sss", [[s/\v(,)\s*/\1\r/g]])
no_search_cabbrev("UE", "UltiSnipsEdit")

-- /* terminal */
local function open_term()
    vim.cmd("split")
    vim.cmd("terminal")
    vim.fn.feedkeys("A")
end

-- /* rc file paths + edit picker */
local coc_settings_json_path = is_win and vim.fn.glob("~/vimfiles/coc-settings.json")
    or vim.fn.glob("~/.vim/coc-settings.json")
local init_lua_path = vim.fn.stdpath("config") .. "/init.lua"

local function edit_rc_files_v2()
    local files = { init_lua_path, my_vimrc_local_path, my_vimrc_path, coc_settings_json_path }
    local n = vim.fn.confirm("To edit:", "&1init.lua\n&2vimrc.local\n&3vimrc\n&4coc.json")
    if n == 0 then
        return
    end
    local ft = vim.bo.filetype
    if vim.fn.winnr() == 1 and (ft == "alpha" or ft == "startify") then
        vim.cmd("silent e " .. files[n])
    else
        vim.cmd("silent vsplit " .. files[n])
    end
end

-- /* quickfix toggle */
local quickfix_is_open = false
local quickfix_return_to_window
local function quickfix_toggle()
    if quickfix_is_open then
        vim.cmd("cclose")
        quickfix_is_open = false
        vim.cmd(quickfix_return_to_window .. "wincmd w")
    else
        quickfix_return_to_window = vim.fn.winnr()
        vim.cmd("copen")
        quickfix_is_open = true
    end
end

-- /* colorscheme support */
local current_hour = tonumber(os.date("%H"))
local bg_light = current_hour >= 8 and current_hour < 17

local function echo_warn(msg)
    vim.api.nvim_echo({ { "[✘] " .. msg, "WarningMsg" } }, true, {})
end

local function init_termguicolors()
    if vim.fn.has("termguicolors") == 1 then
        if not vim.o.termguicolors then
            vim.cmd([[let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"]])
            vim.cmd([[let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"]])
            vim.o.termguicolors = true
        end
        return vim.o.termguicolors
    end
end

local function set_termguicolors(k)
    if vim.fn.has("termguicolors") == 1 then
        if k == "yes" and not vim.o.termguicolors then
            init_termguicolors()
        elseif k == "no" and vim.o.termguicolors then
            vim.o.termguicolors = false
        end
    end
end

local function let_bg_fit_clock()
    vim.o.background = bg_light and "light" or "dark"
end

local function before_change_colorscheme()
    set_termguicolors("no")
    let_bg_fit_clock()
end

local function after_change_colorscheme()
    local term = vim.env.TERM or ""
    local skip_italic = vim.env.TMUX ~= nil and not (term:find("tmux") or term:find("italic"))
    if not skip_italic then
        vim.cmd("highlight Comment cterm=italic")
    end
end

-- FIXME: vimrc itself says "doesn't work at all" -- ported as-is, not fixing
local function backgroud_toggle()
    local cs = vim.g.colors_name
    vim.o.background = vim.o.background == "dark" and "light" or "dark"
    vim.cmd("colorscheme " .. cs)
    vim.api.nvim_echo({ { "Color: " .. cs .. " Background: " .. vim.o.background } }, false, {})
end

-- NOTE: vimrc's SetColorScheme() also fits an airline theme -- dead for nvim,
-- which always uses lualine, so that branch isn't ported.
local function set_color_scheme(cname)
    if vim.g.colors_name ~= nil then
        return
    end
    local chosen = cname
    if bg_light then
        if cname == "seoul256" then
            chosen = "seoul256-light"
        elseif cname == "atomic" then
            vim.g.atomic_mode = 9
        end
    end
    vim.cmd("colorscheme " .. chosen)
end

local function random_set_colo(themes)
    set_color_scheme(themes[math.random(1, #themes)])
end

local fit_cs_grp = vim.api.nvim_create_augroup("fit_colorscheme", { clear = true })
vim.api.nvim_create_autocmd("ColorSchemePre", { group = fit_cs_grp, pattern = "*", callback = before_change_colorscheme })
vim.api.nvim_create_autocmd("ColorSchemePre", {
    group = fit_cs_grp,
    pattern = { "atomic", "NeoSolarized", "ayu", "palenight", "sacredforest" },
    callback = function() set_termguicolors("yes") end,
})
vim.api.nvim_create_autocmd("ColorScheme", { group = fit_cs_grp, pattern = "*", callback = after_change_colorscheme })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = fit_cs_grp, pattern = { "blue-moon", "github_*" }, command = "set nocursorcolumn",
})

-- /* basic keymaps (depend on the functions above) */
vim.keymap.set("n", "<Leader>E", edit_rc_files_v2, mopts)
-- $MYVIMRC under nvim is init.lua; :source auto-detects .lua, so this
-- naturally becomes "reload init.lua"
vim.keymap.set("n", "<Leader>R", "<cmd>source $MYVIMRC<CR><cmd>echom 'Vimrc reloaded :)'<CR>", mopts)
vim.keymap.set("n", "<Leader>S", "<cmd>source %<CR><cmd>echom expand('%') . ' sourced :)'<CR>", mopts)
vim.keymap.set("n", "<Leader>T", open_term, mopts)

vim.keymap.set("n", "<C-n>", "gt", mopts)
vim.keymap.set("n", "<C-p>", "gT", mopts)
vim.keymap.set("n", "<Leader>sw", "<cmd>set wrap!<CR><cmd>set wrap?<CR>", mopts)
vim.keymap.set("n", "<Leader>sb", backgroud_toggle, mopts)
-- overridden later by the `load_lsp_plugins` block's diagnostic.setloclist
-- mapping -- same as current behavior (.vimrc used to be sourced before that
-- block ran too), only takes effect when load_lsp_plugins is false
vim.keymap.set("n", "<leader>q", quickfix_toggle, mopts)
vim.keymap.set("i", "<c-d>", "<Delete>", mopts)
vim.keymap.set("n", "<leader><CR>", "i<CR><ESC>k$", mopts)

-- /* basic options */
vim.opt.errorbells = false
vim.opt.showcmd = true
vim.opt.incsearch = false
vim.opt.ttimeoutlen = 0
vim.opt.wildmenu = true
vim.opt.ruler = true
vim.opt.showtabline = 1
if is_win then
    vim.opt.guifont = "Monaco Nerd Font Mono:h12"
elseif vim.g.neovide == nil then
    vim.opt.guifont = "Monaco Nerd Font Mono 12"
end
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.showmode = true
vim.opt.cmdheight = 2
vim.opt.laststatus = 2
vim.opt.matchtime = 5
vim.opt.wrap = false
-- manual `statusline` intentionally not ported: lualine takes over the
-- statusline whenever it loads (i.e. whenever not vim.g.vscode), so it's
-- dead code in every nvim mode

vim.opt.number = true

local function rel_no_toggle(mode)
    if vim.fn.getbufvar(vim.fn.winbufnr(0), "&nu") == 0 then
        return
    end
    if mode == "in" then
        if vim.wo.number then
            vim.wo.relativenumber = true
        else
            vim.wo.number = true
            vim.wo.relativenumber = true
        end
    elseif mode == "out" then
        if vim.wo.number then
            vim.wo.relativenumber = false
        else
            vim.wo.number = true
            vim.wo.relativenumber = true
        end
    end
end

local relnum_grp = vim.api.nvim_create_augroup("relative_number_toggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
    { group = relnum_grp, pattern = "*", callback = function() rel_no_toggle("in") end })
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
    { group = relnum_grp, pattern = "*", callback = function() rel_no_toggle("out") end })

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.backspace = { "indent", "eol", "start" }
if vim.fn.has("clipboard") == 1 then
    vim.opt.clipboard = "unnamed"
end
if vim.fn.has("gui_running") == 1 then
    vim.keymap.set({ "n", "v", "i" }, "<S-Insert>", "<MiddleMouse>")
end
vim.opt.scrolloff = 5

vim.opt.foldlevel = 99
vim.g.fold_offset = 4
local fold_specs_grp = vim.api.nvim_create_augroup("fold_specs", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = fold_specs_grp, pattern = "vim", callback = function() vim.b.fold_offset = 5 end,
})

vim.opt.spelllang = "en"
vim.opt.spell = false
vim.opt.history = 50
vim.opt.backup = false

vim.opt.fileencodings = { "utf8", "ucs-bom", "gbk", "cp936", "gb2312", "gb18030" }
vim.opt.encoding = "utf-8"
vim.opt.iskeyword:append({ "_", "$", "@", "%", "#", "-" })
vim.opt.fileformat = "unix"

-- filetype-specific formatting + BadWhitespace highlight: kept as a raw
-- vim.cmd block, the `|`-chained regex-heavy autocmds translate poorly to
-- discrete nvim_create_autocmd calls without losing readability
vim.cmd([[
augroup filetype_formats
  au!
  au FileType *
        \ setlocal expandtab         |
        \ setlocal smarttab          |
        \ setlocal shiftwidth=4      |
        \ setlocal tabstop=4         |
        \ setlocal softtabstop=4

  au FileType yaml.docker-compose,toml setlocal sts=2 ts=2 sw=2
  au FileType help setlocal nu
  au FileType make setlocal noexpandtab
  au FileType,BufNewFile,BufRead Jenkinsfile setf groovy

  au FileType,BufNewFile,BufRead *.{vim},*vimrc
        \ setlocal tabstop=2          |
        \ setlocal softtabstop=2      |
        \ setlocal shiftwidth=2       |
        \ setlocal formatoptions-=cro |
        \ setlocal foldlevel=2        |
        \ setlocal foldmethod=expr

  au FileType,BufNewFile,BufRead *.go
        \ setlocal foldmethod=syntax

  au FileType,BufNewFile,BufRead *.py
        \ setlocal autoindent            |
        \ setlocal sidescroll=5          |
        \ setlocal cc=120                |
        \ let b:python_highlight_all = 1 |
        \ setlocal complete+=t           |
        \ setlocal formatoptions-=t      |
        \ setlocal define=^\s*\\(def\\\\|class\\)

  au FileType,BufNewFile,BufRead *.js,*.ts,*.html,*.css,*.yml,*.toml,*.vue
        \ setlocal tabstop=2     |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2

  au FileType,BufNewFile,BufRead *.json
        \ setlocal tabstop=2     |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2  |
        \ setlocal foldmethod=syntax

  au FileType,BufRead,BufNewFile *.py,*.pyw,*.c,*.h,*.{vim,vimrc}
        \ highlight BadWhitespace ctermbg=red guibg=darkred |
        \ match BadWhitespace /\s\+$/
augroup END
]])

vim.cmd([[
augroup file_headers
  au!
  au BufNewFile *.sh
        \ call setline(1, '#!/usr/bin/env bash') | call append(line('.'), '') | normal! Go
  au BufNewFile *.py
        \ call setline(1, '#!/usr/bin/env python') | call append(line('.')+1, '') | normal! Go
  au BufNewFile *.{cpp,cc}
        \ call setline(1, '#include <iostream>') | call append(line('.'), '') | normal! Go
  au BufNewFile *.c
        \ call setline(1, '#include <stdio.h>') | call append(line('.'), '') | normal! Go
  au BufNewFile *.h,*.hpp
        \ call setline(1, '#ifndef _'.toupper(expand('%:r')).'_H') |
        \ call setline(2, '#define _'.toupper(expand('%:r')).'_H') |
        \ call setline(3, '#endif') | normal! Go
augroup END
]])

-- /* fzf.vim config (only relevant if my_fuzzy_tool == "fzf") */
if my_fuzzy_tool == "fzf" then
    local function fzf_to_nvimtree(lines)
        if #lines == 0 then return end
        local path = vim.fn.glob(lines[1])
        if path == "" then
            vim.api.nvim_err_writeln("Invalid path: " .. lines[1])
            return
        end
        vim.cmd("NvimTreeFindFile")
        vim.cmd("wincmd p")
    end

    local function fzf_build_quickfix_list(lines)
        if #lines == 0 then return end
        local qf = {}
        for _, line in ipairs(lines) do
            local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
            if filename then
                table.insert(qf, { filename = filename, lnum = tonumber(lnum), col = tonumber(col), text = text })
            else
                table.insert(qf, { filename = line })
            end
        end
        vim.fn.setqflist(qf, "r")
        vim.cmd("copen")
    end

    vim.g.fzf_action = {
        ["ctrl-n"] = fzf_to_nvimtree,
        ["ctrl-q"] = fzf_build_quickfix_list,
        ["ctrl-t"] = "tab split", ["ctrl-x"] = "split", ["ctrl-v"] = "vsplit",
    }

    vim.g.fzf_vim = {
        preview_window = { "hidden,right,50%,<70(up,40%)", "ctrl-/" },
        buffers_jump = 1, tags_command = "ctags -R",
    }

    if is_win then
        if vim.fn.filereadable([[C:\Program\ Files\Git\git-bash.exe]]) == 1 then
            vim.g.fzf_vim.preview_bash = [[C:\Program\ Files\Git\git-bash.exe]]
        end
    else
        vim.g.fzf_history_dir = "~/.local/share/fzf-history"
    end

    local use_tmux = false
    if not is_win and not vim.g.vscode and vim.env.TMUX ~= nil then
        local ver_str = vim.fn.system("tmux -V"):match("[%d%.]+")
        if ver_str and tonumber(ver_str) and tonumber(ver_str) >= 3.2 then
            use_tmux = true
        end
    end

    if use_tmux then
        vim.g.fzf_layout = { tmux = "-p90%,60%" }
    else
        -- vimrc's `has('nvim') || has("popupwin")` is always true for nvim,
        -- only the floating-window branch is relevant here
        vim.g.fzf_layout = { window = { width = 0.9, height = 0.6 } }
        vim.g.fzf_colors = {
            fg = { "fg", "Normal" }, bg = { "bg", "Normal" }, hl = { "fg", "Comment" },
            ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
            ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
            ["hl+"] = { "fg", "Statement" }, info = { "fg", "PreProc" },
            border = { "fg", "Ignore" }, prompt = { "fg", "Conditional" },
            pointer = { "fg", "Exception" }, marker = { "fg", "Keyword" },
            spinner = { "fg", "Label" }, header = { "fg", "Comment" },
        }
    end

    vim.cmd([[command! -bar -nargs=? -bang Maps call fzf#vim#maps(<q-args>, <bang>0)]])

    vim.keymap.set("n", "<Leader>ff", "<cmd>Files<CR>", { noremap = true })
    vim.keymap.set("n", "<Leader>fa", is_win and ":Rg<Space>" or ":Ag<Space>", { noremap = true })
    vim.keymap.set("n", "<Leader>fr", ":Rg<Space>", { noremap = true })
    vim.keymap.set("n", "<Leader>fg", ":Rg<Space>", { noremap = true })
    vim.keymap.set("n", "<Leader>fl", ":Lines<Space>", { noremap = true })
    vim.keymap.set("n", "<Leader>fL", ":BLines<Space>", { noremap = true })
    vim.keymap.set("n", "<Leader>fb", "<cmd>Buffers<CR>", { noremap = true })
    vim.keymap.set("n", "<Leader>fw", "<cmd>Windows<CR>", { noremap = true })
    vim.keymap.set("n", "<Leader>fs", "<cmd>Snippets<CR>", { noremap = true })
    vim.keymap.set("n", "<Leader>fq", "<cmd>FzfQF<CR>", { noremap = true })
end

-- /* vim-easy-align */
vim.keymap.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)")

-- /* easymotion (net effect: normal mode uses overwin-w, visual/o-p uses bd-w) */
vim.keymap.set({ "n", "x", "o" }, "<Leader>w", "<Plug>(easymotion-bd-w)")
vim.keymap.set("n", "<Leader>w", "<Plug>(easymotion-overwin-w)")

-- /* ultisnips extras (UltiSnipsExpandTrigger already set in the lazy-spec) */
vim.g.UltiSnipsEditSplit = "context"
vim.g.UltiSnipsUsePythonVersion = 3
vim.g.UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = my_vimroot .. "/mysnippets"
vim.g.UltiSnipsSnippetDirectories = { my_vimroot .. "/mysnippets", "UltiSnips" }
vim.g.UltiSnipsEnableSnipMate = 1
vim.g.UltiSnipsNoPythonWarning = 1
vim.g.snips_author = "k"
vim.g.snips_email = "valesail7@gmail.com"
vim.g.snips_github = "https://github.com/Karmenzind/"

-- /* vim-visual-multi (fixing the vimrc `exists("vscode")` bug -- see the
--    Vista block further down for the same fix and explanation) */
if not vim.g.vscode then
    vim.g.VM_maps = { ["Find Under"] = "<leader><leader>n" }
end

-- /* vim-markdown */
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_no_default_key_mappings = 1
vim.g.vim_markdown_json_frontmatter = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_conceal_code_blocks = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1

-- /* markdown-preview.nvim */
vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_open_ip = "0.0.0.0"
vim.g.mkdp_port = "13333"
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_open = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_preview_options = {
    mkit = {}, katex = {}, uml = {}, maid = {},
    disable_sync_scroll = 1, sync_scroll_type = "middle", hide_yaml_meta = 1,
    sequence_diagrams = {}, flowchart_diagrams = {},
    content_editable = false, disable_filename = 0, toc = {},
}
vim.g.mkdp_browser = "chromium"

-- /* misc filetype augroups */
local jsfold_grp = vim.api.nvim_create_augroup("javascript_folding", { clear = true })
vim.api.nvim_create_autocmd("FileType", { group = jsfold_grp, pattern = "javascript", command = "setlocal foldmethod=syntax" })

local nginx_grp = vim.api.nvim_create_augroup("custom_nginx", { clear = true })
vim.api.nvim_create_autocmd("FileType", { group = nginx_grp, pattern = "nginx", command = "setlocal iskeyword+=$" })
-- skipped `let b:coc_additional_keywords`: coc.nvim isn't used under nvim

local mdft_grp = vim.api.nvim_create_augroup("for_markdown_ft", { clear = true })
vim.api.nvim_create_autocmd("FileType", { group = mdft_grp, pattern = "markdown", command = "cabbrev <buffer> TF TableFormat" })
-- skipped the b:AutoPairs dict: that's for the vim-only jiangmiao/auto-pairs
-- plugin, nvim uses windwp/nvim-autopairs with a different config surface

-- /* markdown preview: multi-tool picker (redesigned, not a straight port) */
local function mp_term_execute(cmd)
    if vim.env.TMUX then
        vim.fn.system(string.format('tmux split-window "%s"', cmd))
    else
        vim.cmd("split")
        vim.cmd("terminal " .. cmd)
    end
end

local function mp_get_browser()
    if is_win then
        local p = [[C:\Program Files\Google\Chrome\Application\chrome.exe]]
        return vim.fn.glob(p) ~= "" and p or nil
    end
    for _, p in ipairs({ "google-chrome", "google-chrome-stable", "chromium", "firefox" }) do
        if vim.fn.executable(p) == 1 then
            return p
        end
    end
    return nil
end

local function mp_app_available(exe, mac_app)
    if is_macos and mac_app and vim.fn.isdirectory("/Applications/" .. mac_app .. ".app") == 1 then
        return true
    end
    return vim.fn.executable(exe) == 1
end

local function mp_launch_mlp(path)
    mp_term_execute(string.format("mlp --no-browser -p 13333 -o %s", vim.fn.fnameescape(path)))
    local browser = mp_get_browser()
    if not browser then
        echo_warn("Available browser not found.")
    else
        mp_term_execute(browser .. " http://localhost:13333")
    end
end

local function mp_launch_glow(path)
    mp_term_execute("glow " .. vim.fn.fnameescape(path))
end

local function mp_launch_app(exe, mac_app, path)
    if is_macos and vim.fn.executable(exe) == 0 and mac_app then
        vim.fn.jobstart({ "open", "-a", mac_app, path }, { detach = true })
    else
        vim.fn.jobstart({ exe, path }, { detach = true })
    end
end

-- NOTE: obsidian can only preview a file that's already inside a vault it
-- has open, this is best-effort
local function markdown_preview_picker()
    if vim.bo.filetype ~= "markdown" then
        echo_warn("Only support markdown")
        return
    end
    local path = vim.fn.expand("%")
    local candidates = {}

    if vim.fn.executable("mlp") == 1 then
        table.insert(candidates, { name = "mlp", launch = function() mp_launch_mlp(path) end })
    end
    if vim.fn.executable("glow") == 1 then
        table.insert(candidates, { name = "glow", launch = function() mp_launch_glow(path) end })
    end
    if is_macos and mp_app_available("marktext", "MarkText") then
        table.insert(candidates, { name = "marktext", launch = function() mp_launch_app("marktext", "MarkText", path) end })
    end
    if mp_app_available("typora", "Typora") then
        table.insert(candidates, { name = "typora", launch = function() mp_launch_app("typora", "Typora", path) end })
    end
    if mp_app_available("obsidian", "Obsidian") then
        table.insert(candidates, {
            name = "obsidian (best-effort, needs an already-open vault)",
            launch = function() mp_launch_app("obsidian", "Obsidian", path) end,
        })
    end
    if vim.fn.executable("code") == 1 then
        table.insert(candidates, { name = "vscode", launch = function() vim.fn.jobstart({ "code", path }, { detach = true }) end })
    end

    if #candidates == 0 then
        echo_warn("No markdown preview tool found (mlp/glow/marktext/typora/obsidian/vscode)")
        return
    end

    local names = {}
    for _, c in ipairs(candidates) do
        table.insert(names, c.name)
    end

    vim.ui.select(names, { prompt = "Markdown preview with:" }, function(_, idx)
        if idx then
            candidates[idx].launch()
        end
    end)
end

vim.keymap.set("n", "<Leader>mp", markdown_preview_picker)

-- /* vim-atomic colorscheme vars + keymaps (CycleModes() is undefined
--    anywhere in the codebase -- ported faithfully per explicit instruction,
--    will error at runtime if <Leader>cm is triggered) */
vim.g.atomic_mode = 21
vim.g.atomic_italic = 1
vim.g.atomic_bold = 1
vim.g.atomic_underline = 1
vim.g.atomic_undercurl = 1
vim.keymap.set("n", "<Leader>cm", "<cmd>call CycleModes()<CR><cmd>colorscheme atomic<CR>")
vim.keymap.set("x", "<Leader>cm", ":<C-u>call CycleModes()<CR>:colorscheme atomic<CR>gv")

-- /* GUI (Neovide) compatibility -- classic-Vim guioptions block and the
--    Windows gvim delmenu.vim/menu.vim block intentionally not ported,
--    neither has a Neovide equivalent */
if vim.fn.has("gui_running") == 1 and not vim.g.vscode then
    vim.o.lines = 77
    vim.o.columns = 150
    vim.o.winaltkeys = "no"
    vim.o.langmenu = "en_US"
    vim.env.LANG = "en_US.UTF-8"
    vim.opt.list = false
end

-- /* load ~/.vimrc.local (replaces both the old vimrc-tail sourcing and the
--    dead init.vim.local mechanism) */
if vim.fn.filereadable(vim.fn.expand(my_vimrc_local_path)) == 1 then
    vim.cmd("source " .. my_vimrc_local_path)
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
    echo_warn("Failed to load " .. mod)
    return nil
end

local function lazy_esc(_)
    vim.keymap.set("t", "<Esc>", term_esc, mopts)
end

if my_fuzzy_tool == "fzf" then
    vim.api.nvim_create_augroup("fzf", {})
    vim.api.nvim_create_autocmd({ "BufEnter" }, { group = "fzf", pattern = "*", callback = lazy_esc })
    if vim.g.fzf_layout["window"] == nil and vim.g.fzf_layout["tmux"] == nil then
        vim.api.nvim_create_autocmd({ "BufLeave" }, { group = "fzf", command = "set ls=2 smd ru" })
        vim.api.nvim_create_autocmd(
            { "FileType" },
            { group = "fzf", pattern = "fzf", command = "setl ls=0 nosmd noru" }
        )
    end
    -- require('fzf-lua').setup({'fzf-tmux'})
end

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

    vim.keymap.set("n", "<leader>n", vscode_cmd("workbench.action.toggleSidebarVisibility"), mopts)
    vim.keymap.set("n", "<leader>N", vscode_cmd("workbench.action.toggleSidebarVisibility"), mopts)
else
    -- Structure / Files / Outline
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
end

-- /* Outline & vista.vim */
-- NOTE: vimrc guards this with `if !exists("vscode")` -- a bare, unprefixed
-- variable that never exists in either plain Vim or VSCode-Neovim (it should
-- be `exists('g:vscode')`, as used correctly elsewhere in that file). That
-- means today the VSCode outline-map keymap is dead code even inside real
-- VSCode-Neovim. This port fixes that by using vim.g.vscode; .vimrc itself is
-- left untouched since Vim never runs inside VSCode anyway.
if not vim.g.vscode then
    vim.g.vista_sidebar_width = 40
    vim.g.vista_echo_cursor = 0
    vim.g.vista_echo_cursor_strategy = "both"
    vim.g.vista_executive_for = {
        go = "nvim_lsp", yaml = "nvim_lsp", toml = "ctags", typescript = "nvim_lsp",
    }

    vim.keymap.set("n", "<Leader>V", "<cmd>Vista!!<CR>", mopts)
    vim.keymap.set("n", "<Leader>fc", "<cmd>Vista finder<CR>", mopts)

    local vista_grp = vim.api.nvim_create_augroup("vista_aug", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = vista_grp,
        pattern = { "vista", "vista_kind" },
        callback = function()
            vim.wo.number = true
            vim.wo.relativenumber = true
            vim.keymap.set("n", "K", "<cmd>call vista#cursor#TogglePreview()<CR>",
                { buffer = true, silent = true, noremap = true })
        end,
    })
else
    vim.keymap.set("n", "<Leader>V", vscode_cmd("workbench.view.extension.outline-map"), mopts)
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
if load_lsp_plugins then
    cmp = require("cmp")
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
end

-- LSP Configs
if load_lsp_plugins then
    local lsp_cap = require("cmp_nvim_lsp").default_capabilities()
    -- local lsp_cap = vim.lsp.protocol.make_client_capabilities()
    -- lsp_cap.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
    -- lsp_cap.textDocument.completion.completionItem.snippetSupport = true

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
        vim.keymap.set({ "x", "v" }, "<leader>lf", function()
            local start_pos = vim.api.nvim_buf_get_mark(0, "<")
            local end_pos = vim.api.nvim_buf_get_mark(0, ">")
            vim.lsp.buf.format({
                range = {
                    ["start"] = { start_pos[1] - 1, start_pos[2] },
                    ["end"] = { end_pos[1] - 1, end_pos[2] },
                },
            })
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

    vim.lsp.enable(my_lsps)
    vim.lsp.config("*", { capabilities = lsp_cap })

    vim.lsp.config("taplo", { settings = { evenBetterToml = { schema = { enabled = false } } } })

    vim.lsp.config("jdtls", {
        settings = {
            java = {
                format = {
                    enabled = true,
                    settings = {
                        url = "file://" .. home .. ".config/eclipse/eclipse-formatter.xml",
                    },
                },
            },
        },
    })

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
                runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
                workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            })
        end,
        settings = {
            Lua = {},
        },
    })

    if vim.fn.has("win32") == 1 then
        vim.lsp.config("omnisharp", {
            handlers = { ["textDocument/definition"] = require("omnisharp_extended").handler },
        })
    else
        vim.lsp.config("omnisharp", {
            cmd = { "/bin/OmniSharp", "--languageserver", "--hostPID", tostring(nvimpid) },
            handlers = { ["textDocument/definition"] = require("omnisharp_extended").handler },
        })
    end

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
        echo_warn("Invalid ps_bundle_path")
    end

    require("lspsaga").setup({
        finder = { keys = { toggle_or_open = "<cr>" } },
        lightbulb = { virtual_text = true, sign = false },
    })
else
    vim.keymap.set("n", "<leader>rn", vscode_cmd("editor.action.rename"), mopts)
end

require("nvim-autopairs").setup({ disable_filetype = { "markdown" } })
if load_lsp_plugins then
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

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
if load_lsp_plugins then
    local dap = require("dap")
    vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
    dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
    -- require("dap-python").setup("uv")
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

-- if not vim.g.vscode and my_mode ~= "light" then
--     require("registers").setup({})
-- end

if load_lsp_plugins then
    cmp.setup({
        enabled = function()
            return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt"
                or require("cmp_dap").is_dap_buffer()
        end,
    })
    cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, { sources = { { name = "dap" } } })
end

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

-- FIXME (k): <2024-05-02 22:24>
-- require("ufo").setup({ close_fold_kinds_for_ft = { "imports", "comment" }, fold_virt_text_handler = ufo_handler })

local function rchoose(l)
    return l[math.random(1, #l)]
end

if vim.g.colors_name == nil then
    if load_extra_colors then
        vim.g.boo_colorscheme_theme =
            rchoose({ "sunset_cloud", "radioactive_waste", "forest_stream", "crimson_moonlight" })
        random_set_colo({
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
    else
        set_color_scheme("default")
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

-- -----------------------------------------------------------------------------
-- Test
-- -----------------------------------------------------------------------------

vim.keymap.set("n", "<leader>kd", ":TranslateNormal<CR>")
vim.keymap.set("v", "<leader>kd", ":TranslateVisual<CR>")

vim.api.nvim_create_user_command("CleanJdtls", function()
    local paths = {
        vim.fn.stdpath("cache") .. "/jdtls",
        vim.fn.stdpath("data") .. "/jdtls",
    }
    for _, path in ipairs(paths) do
        vim.fn.delete(path, "rf")
    end
    print("Deleted JDTLS cache!")
end, {})
