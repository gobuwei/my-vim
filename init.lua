------------------------------------------------------------
-- Vim settings
------------------------------------------------------------
vim.opt.mousemoveevent = true
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.showtabline = 2
vim.opt.signcolumn = "number" -- "yes", "no", "auto", "number"
vim.diagnostic.config({
    signs = false,            -- removes the signs in the signcolumn
    virtual_text = false,     -- removes the inline text on the right
    underline = false,        -- removes the underline on the affected code
})

------------------------------------------------------------
-- Plugin installation and setup
------------------------------------------------------------
vim.pack.add({ { src = 'https://github.com/folke/lazy.nvim' }, })

require("lazy").setup({
    -- Color schemes
    { "rktjmp/lush.nvim" },
    { "ellisonleao/gruvbox.nvim",       priority = 1000, config = true, opts = {} },

    { "neovim/nvim-lspconfig" },
    { "mason-org/mason.nvim",           opts = {} },
    { "mason-org/mason-lspconfig.nvim", opts = {} },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                api.config.mappings.default_on_attach(bufnr)
                -- Don't use <Tab> key in vim-tree buffer
                vim.keymap.del("n", "<Tab>", { buffer = bufnr })
            end,
        }
    },
    {
        'nanozuki/tabby.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            local theme = {
                fill = 'TabLineFill',
                head = 'TabLine',
                current_tab = 'TabLineSel',
                tab = 'TabLine',
                win = 'TabLine',
                tail = 'TabLine',
            }
            require('tabby').setup({
                line = function(line)
                    return {
                        {
                            { '  ', hl = { fg = '#7FBBB3', bg = '#414B50' } },
                            line.sep('', theme.head, theme.fill),
                        },
                        line.tabs().foreach(function(tab)
                            local hl = tab.is_current() and theme.current_tab or theme.tab

                            -- remove count of wins in tab with [n+] included in tab.name()
                            local name = tab.name()
                            local index = string.find(name, "%[%d")
                            local tab_name = index and string.sub(name, 1, index - 1) or name

                            -- indicate if any of buffers in tab have unsaved changes
                            local modified = false
                            local win_ids = require('tabby.module.api').get_tab_wins(tab.id)
                            for _, win_id in ipairs(win_ids) do
                                if pcall(vim.api.nvim_win_get_buf, win_id) then
                                    local bufid = vim.api.nvim_win_get_buf(win_id)
                                    if vim.api.nvim_buf_get_option(bufid, "modified") then
                                        modified = true
                                        break
                                    end
                                end
                            end

                            return {
                                line.sep('', hl, theme.fill),
                                tab.number(),
                                tab_name,
                                modified and '',
                                tab.close_btn(''),
                                line.sep('', hl, theme.fill),
                                hl = hl,
                                margin = ' ',
                            }
                        end),
                        line.spacer(),
                        {
                            line.sep('', theme.tail, theme.fill),
                            { '  ', hl = theme.tail },
                        },
                        hl = theme.fill,
                    }
                end,
            })
        end,
    },
    {
        "akinsho/bufferline.nvim",
        enabled = false,
        opts = {
            options = {
                numbers = "buffer_id",
                -- Show close sign 'x' only when hovering on
                always_show_bufferline = false,
                hover = {
                    enabled = true,
                    reveal = { 'close' }
                },
            }
        }
    },
    { "famiu/bufdelete.nvim" },
    { "numtostr/comment.nvim", opts = {} },
    { "karb94/neoscroll.nvim", opts = {} },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
    },
    { "liuchengxu/vista.vim", cmd = "Vista" },
    -- { "linrongbin16/gentags.nvim", opts = {} },
    -- { "ludovicchabant/vim-gutentags" },
})

vim.opt.background = "dark" -- or "light" for light mode
vim.cmd.colorscheme "gruvbox"

require("telescope").load_extension("fzf")
-- require("telescope").load_extension("gtags")

-- gutentags config
-- vim.g.gutentags_modules = { "gtags_cscope" }
-- vim.g.gutentags_project_root = { ".git", ".root", ".svn" }
-- vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/gutentags")
-- vim.g.gutentags_plus_switch = 1
-- vim.g.gutentags_define_advanced_commands = 1

------------------------------------------------------------
-- Local functions
------------------------------------------------------------

local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

local function cword() return vim.fn.expand("<cword>") end
local function cfile() return vim.fn.expand("<cfile>") end

local function set_indent(width)
    vim.opt.shiftwidth = width
    vim.opt.tabstop = width
    vim.opt.expandtab = width ~= 8
end

-- Cycle tab width among 2, 4, 8
local function cycle_indent()
    local current = vim.opt.shiftwidth:get()

    local next_width
    if current == 2 then
        next_width = 4
    elseif current == 4 then
        next_width = 8
    else
        next_width = 2
    end

    set_indent(next_width)

    print("Indentation set to " .. next_width .. " (expandtab="
        .. tostring(vim.opt.expandtab:get()) .. ")")
end

local function toggle_diagnostic()
    local value = not vim.diagnostic.config().signs,
        vim.diagnostic.config({
            signs = value,
            virtual_text = value,
            underline = value,
        })
end

local function toggle_signcolumn()
    if vim.opt.signcolumn:get() == "no" then
        vim.opt.signcolumn = "number"
    else
        vim.opt.signcolumn = "no"
    end
end

local function toggle_quickfix()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        buf = vim.api.nvim_win_get_buf(win)
        buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        if buftype == "quickfix" then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end

------------------------------------------------------------
--  GNU Global (gtags) → Quickfix
------------------------------------------------------------

local function global_find(mode)
    local word = cword()
    local cmd = { "global", "-x", mode, word }
    local result = vim.fn.systemlist(cmd)

    if vim.v.shell_error ~= 0 or #result == 0 then
        print("GTAGS: no results for " .. word)
        return
    end

    -- Convert global output to quickfix items
    local qf_list = {}
    for _, line in ipairs(result) do
        local sym, lnum, file, text = string.match(line, "(%S+)%s+(%d+)%s+(%S+)%s+(.*)")
        if file and lnum then
            table.insert(qf_list, {
                filename = file,
                lnum = tonumber(lnum),
                text = text,
            })
        end
    end

    -- Only push to quickfix if we actually have entries
    if #qf_list == 0 then
        print("GTAGS: no entries for " .. word)
        return
    end

    vim.fn.settagstack(0, { items = items }, 'r')

    --  If only ONE match → jump directly
    if #qf_list == 1 then
        local item = qf_list[1]
        vim.fn.settagstack()
        vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
        vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
        return
    end

    -- Push into quickfix and open it
    vim.fn.setqflist(qf_list, "r")
    -- vim.api.nvim_create_autocmd("QuickFixCmdPre", {
    --     pattern = { "cc", "cnext", "cprev", "cfirst", "clast" },
    --     callback = toggle_quickfix
    -- pattern = { "cc" },
    -- vim.cmd("cclose")
    -- callback = function() pcall(vim.fn.setjump) end,
    -- callback = function() pcall(push_jump) end,
    --     vim.cmd("tjump " .. tags[1].name)
    -- })
    -- vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    -- pattern = { "cc" },
    -- pattern = { "cc", "cnext", "cprev", "cfirst", "clast" },
    --     callback = function() pcall(push_jump) end,
    --     once = true, -- only apply to this GTAGS search
    -- pattern = { "cc" },
    -- callback = toggle_quickfix
    -- })
    vim.cmd("copen " .. math.min(#qf_list, 8))
end

local function global_keymap()
    vim.fn.system("global -pq")

    if vim.v.shell_error == 0 then
        print("GTAGS keymaps is used")

        map("n", "f", function() global_find("-d") end)
        map("n", "gt", function() global_find("-r") end)
        map("n", "gs", function() global_find("-s") end)
        map("n", "ge", function() global_find("-g") end)

        map("n", "F", ":!global -u<CR>", {})
    end
end

local function push_tag_items(items)
    vim.fn.settagstack(0, { items = items }, 'r')
end

local function jump_with_tagstack(items)
    if #items == 0 then
        print("No results")
        return
    end

    push_tag_items(items)

    if #items == 1 then
        print("name: " .. items[1].name)
        vim.cmd("tjump " .. items[1].name)
    else
        vim.cmd("tselect " .. items[1].name)
    end
end

local function lsp_locations_to_tags(result)
    local items = vim.lsp.util.locations_to_items(result, 0)
    local tags = {}

    for _, it in ipairs(items) do
        table.insert(tags, {
            name = it.text or it.filename,
            filename = it.filename,
            cmd = string.format(":%d", it.lnum),
        })
    end

    return tags
end

local function gtags_query(flag, word)
    local cmd = { "global", "-x", flag, word }
    local lines = vim.fn.systemlist(cmd)
    print(lines)
    if vim.v.shell_error ~= 0 then return {} end
    return lines
end

local function gtags_to_tags(lines)
    local tags = {}
    for _, line in ipairs(lines) do
        local name, file, ex = line:match("^(%S+)%s+(%S+)%s+(.+)$")
        if name and file and ex then
            table.insert(tags, { name = name, filename = file, cmd = ex })
        end
    end
    return tags
end

local function unified_definition()
    local params = vim.lsp.util.make_position_params()

    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
        if not err and result and not vim.tbl_isempty(result) then
            -- LSP succeeded
            local tags = lsp_locations_to_tags(result)
            jump_with_tagstack(tags)
            return
        end

        -- LSP failed → try GTAGS
        local word = cword()
        local lines = gtags_query("-d", word)
        if #lines > 0 then
            local tags = gtags_to_tags(lines)
            jump_with_tagstack(tags)
            return
        end

        -- GTAGS failed → try ctags
        vim.cmd("tjump " .. word)
    end)
end

local function unified_declaration()
    local params = vim.lsp.util.make_position_params()

    vim.lsp.buf_request(0, "textDocument/declaration", params, function(err, result)
        if not err and result and not vim.tbl_isempty(result) then
            local tags = lsp_locations_to_tags(result)
            jump_with_tagstack(tags)
            return
        end

        local word = vim.fn.expand("<cword>")
        local lines = gtags_query("-s", word)
        if #lines > 0 then
            local tags = gtags_to_tags(lines)
            jump_with_tagstack(tags)
            return
        end

        vim.cmd("tjump " .. word)
    end)
end

local function unified_references()
    local params = vim.lsp.util.make_position_params()

    vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
        if not err and result and not vim.tbl_isempty(result) then
            local tags = lsp_locations_to_tags(result)
            jump_with_tagstack(tags)
            return
        end

        local word = vim.fn.expand("<cword>")
        local lines = gtags_query("-r", word)
        if #lines > 0 then
            local tags = gtags_to_tags(lines)
            jump_with_tagstack(tags)
            return
        end

        print("No references found")
    end)
end

vim.api.nvim_create_user_command("Def", unified_definition, {})
vim.api.nvim_create_user_command("Decl", unified_declaration, {})
vim.api.nvim_create_user_command("Ref", unified_references, {})

------------------------------------------------------------
-- Key maps
------------------------------------------------------------

vim.keymap.set("n", "*", function()
    vim.fn.setreg("/", "\\V" .. cword())
    vim.opt.hlsearch = true
end, { noremap = true, silent = true })

-- Copy/paste from/to from system clipboard
map("n", "yp", '"+p\']', { desc = "Paste from system clipboard" })
map("n", "Y", '"+yy', { desc = "Copy one line to system clipboard" })
map("v", "Y", '"+y', { desc = "Copy selected" })

-- Tabpage management
map({"n", "v"}, "tt", "<cmd>tab split<CR>", { desc = "Split window horizontally" })
map({"n", "v"}, "tn", "<cmd>tab split<CR>", { desc = "Split window horizontally" })
map({"n", "v"}, "tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map({"n", "v"}, "tc", function() vim.cmd(vim.v.count .. "tabclose") end, { desc = "Close tab" })
map({"n", "v"}, "tm", function() vim.cmd(vim.v.count .. "tabmove") end, { desc = "Move tab" })
map({"n", "v"}, "t[", "<cmd>-tabmove<CR>", { desc = "Move tab to the left" })
map({"n", "v"}, "t]", "<cmd>+tabmove<CR>", { desc = "Move tab to the right" })
map({"n", "v"}, "<C-k>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map({"n", "v"}, "<C-l>", "<cmd>tabnext<CR>", { desc = "Next tab" })


-- Window management
map("n", "<Tab>", "<C-w>w", { desc = "Next window" })
map("n", "<S-Tab>", "<C-w>W", { desc = "Previous window" })
map("n", "ss", "<C-w>s", { desc = "Split window horizontally" })
map("n", "sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "sq", "<C-w>q", { desc = "Close window" })
map("n", "sh", "<C-w>H", { desc = "Move window leftward" })
map("n", "sj", "<C-w>J", { desc = "Move window downward" })
map("n", "sk", "<C-w>K", { desc = "Move window upward" })
map("n", "sl", "<C-w>L", { desc = "Move window rightward" })

-- Tab/Buffer management
-- map("n", "<C-k>", "<cmd>bp<CR>", { desc = "Previous buffer" })
-- map("n", "<C-l>", "<cmd>bn<CR>", { desc = "Next buffer" })
map("n", "<C-n>", "<cmd>cn<CR>", { desc = "Next error" })
map("n", "<C-p>", "<cmd>cp<CR>", { desc = "Previous error" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Code navigation
map("n", "e", ":pop<CR>", { silent = true })
map("n", "f", vim.lsp.buf.definition, {})
map("n", "gd", vim.lsp.buf.declaration, {})
map("n", "gi", vim.lsp.buf.implementation, {})
map("n", "gr", vim.lsp.buf.references, {})
map("n", "gt", vim.lsp.buf.type_definition, {})
map("n", "gh", vim.lsp.buf.hover, {})

-- <Space> key leading
map("n", " ti", cycle_indent, { silent = true })
map("n", " tf", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Vista tagbar" })
map("n", " tt", "<cmd>Vista!!<CR>", { silent = true })
map("n", " td", toggle_diagnostic, { silent = true })
map("n", " ts", toggle_signcolumn, { silent = true })
map("n", " th", function()
    vim.opt.hlsearch = not vim.opt.hlsearch:get()
end, { noremap = true, silent = true })
map("n", " tq", toggle_quickfix, { desc = "Toggle quickfix" })
map("n", " df", function() vim.diagnostic.open_float() end, {})
map("n", " dn", function() vim.diagnostic.goto_next() end, {})
map("n", " dp", function() vim.diagnostic.goto_prev() end, {})
map("n", " tr", function() vim.wo.wrap = not vim.wo.wrap end, {})

map("n", " tn", function()
    vim.opt.number = not vim.opt.number:get()
end, { desc = "Toggle line number" })
map("n", " tN", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line number" })

map("n", " fm", function() vim.lsp.buf.format() end, {})

-- comment.nvim plugin
map("n", "mm", "gcc", { remap = true, silent = true })
map("n", "mb", "gbc", { remap = true, silent = true })
map("v", "mm", "gc", { remap = true, silent = true })
map("v", "mb", "gb", { remap = true, silent = true })

-- telescope.nvim plugin
local builtin = require("telescope.builtin")
map("n", " ff", builtin.find_files)
map("n", " fg", builtin.live_grep)
map("n", " fb", builtin.buffers)
map("n", " fh", builtin.help_tags)

-- neoscroll.nvim plugin
local neoscroll = require("neoscroll")
map({ "n", "v" }, "<C-j>", function() neoscroll.ctrl_d({ duration = 300 }) end)
map({ "n", "v" }, "<C-h>", function()
    neoscroll.scroll(3, { move_cursor = false, duration = 100 })
end)

------------------------------------------------------------
-- AutoCmd
------------------------------------------------------------

-- Indentation
autocmd("FileType", {
    pattern = "sh,go,lua",
    callback = function() set_indent(4) end,
})

-- Jump to the last cursor position when reopened
autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

-- Auto resize quickfix window heigth
autocmd("FileType", {
    pattern = "qf",
    callback = function()
        local max_height = 8
        local line_count = vim.fn.line("$")
        vim.api.nvim_win_set_height(0, math.min(line_count, max_height))
    end,
})
-- global_keymap()
