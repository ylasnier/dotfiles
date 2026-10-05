-- Converted from ~/.vimrc and ~/.gvimrc. Options that are already Neovim defaults (nocompatible,
-- syntax on, encoding, backspace, wildmenu, laststatus, hidden, showcmd, ruler...) are left out.

local opt = vim.opt

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.number = true
opt.title = true
opt.mouse = "a"
opt.confirm = true
opt.report = 0 -- always report the number of substitutions done with :s
opt.showmatch = true
opt.matchtime = 2
opt.scrolloff = 2
opt.sidescrolloff = 2

vim.g.mapleader = ","

-- Neovim has no 'autoselect'; unnamedplus shares the system clipboard (macOS: "unnamed")
opt.clipboard = "unnamedplus"

opt.background = "dark" -- colorscheme is set after the plugins are loaded
opt.fillchars:append({ eob = " " }) -- hide the ~ on lines past the end of the buffer
opt.guicursor = "a:hor20-Cursor"
opt.mousemodel = "popup"

-- the vimrc kept filetype indent off; Neovim turns it on unless told otherwise
vim.cmd("filetype indent off")

opt.fileformats = { "unix", "dos", "mac" }
opt.fileencodings = { "utf-8", "latin1" }

opt.ignorecase = true
opt.smartcase = true

-- Neovim's default rg grepprg passes -uu (searches ignored/hidden files); respect .gitignore instead
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

opt.wildmode = { "longest", "list" }
opt.wildignore:append({
  "*.o", "*.dll", "*.obj", "*.exe", "*.pyc", "*.a", "*.class", "*.mo", "*.la", "*.so",
  "*.beam",
  "*~", "*.bak",
  "*.jpg", "*.gif", "*.png", "*.xpm",
  ".svn", "CVS", ".git",
  "doc*", "build*", "cmake", "resources",
  "*SUITE_data/",
  ".DS_Store",
})

------------------------------------------------------------------------------------------------
-- Keymaps (plugin keymaps live next to their plugin's setup, below)
------------------------------------------------------------------------------------------------

local map = vim.keymap.set

map("ia", "prinfo", '?PRINT_INFO("[] ~p", [log_format__([])])')
map("ia", "prdebug", '?PRINT_DEBUG("[] ~p", [log_format__([])])')
map("ia", "prwarn", '?PRINT_WARNING("[] ~p", [log_format__([])])')
map("ia", "prerr", '?PRINT_ERROR("[] ~p", [log_format__([])])')

-- emacs bindings in command mode
map("c", "<C-a>", "<Home>")
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
map("c", "<C-d>", "<Delete>")
map("c", "<M-b>", "<S-Left>")
map("c", "<M-f>", "<S-Right>")
map("c", "<M-d>", "<S-Right><Delete>")
map("c", "<M-BS>", "<S-Left><Delete>")
map("c", "<Esc><BS>", "<S-Left><Delete>")
map("c", "<C-g>", "<C-c>")

-- `w !sudo tee` can't prompt for a password in Neovim; vim-eunuch's :SudoWrite can
map("c", "w!!", "SudoWrite")

-- split window navigation
map("n", "<A-Left>", "<C-w><C-h>")
map("n", "<A-Right>", "<C-w><C-l>")
map("n", "<A-Down>", "<C-w><C-j>")
map("n", "<A-Up>", "<C-w><C-k>")

-- tab navigation
map("n", "<C-Left>", "<cmd>tabprevious<CR>")
map("n", "<C-Right>", "<cmd>tabnext<CR>")
map("i", "<C-Left>", "<Esc><cmd>tabprevious<CR>")
map("i", "<C-Right>", "<Esc><cmd>tabnext<CR>")
map("i", "<C-t>", "<Esc><cmd>tabnew<CR>")
map("n", "<C-S-Left>", "<cmd>tabmove -1<CR>")
map("n", "<C-S-Right>", "<cmd>tabmove +1<CR>")

-- <C-w> wipes the buffer, shadowing the window prefix (<A-arrows> still move between splits).
-- The default <C-w>d mappings are dropped, otherwise <C-w> waits 'timeoutlen' for a second key.
pcall(vim.keymap.del, "n", "<C-w>d")
pcall(vim.keymap.del, "n", "<C-w><C-d>")
map("n", "<C-w>", "<cmd>bwipeout<CR>")
map("i", "<C-w>", "<Esc><cmd>bwipeout<CR>")

------------------------------------------------------------------------------------------------
-- Autocommands
------------------------------------------------------------------------------------------------

-- cleared on every (re)source so re-sourcing init.lua doesn't stack duplicate autocmds
local group = vim.api.nvim_create_augroup("vimrc", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

-- highlight trailing and non-breakable spaces
-- a colorscheme clears custom highlight groups, so define it again after each one
autocmd("ColorScheme", {
  callback = function() vim.api.nvim_set_hl(0, "UnwantedSpace", { bg = "darkred", ctermbg = "darkred" }) end,
})
local unwanted_space = [[\s\+$\|\%u00a0]]
local unwanted_space_while_typing = [[\s\+\%#\@<!$\|\%u00a0]] -- ignore trailing space at cursor
autocmd({ "BufWinEnter", "InsertLeave" }, { command = "match UnwantedSpace /" .. unwanted_space .. "/" })
autocmd("InsertEnter", { command = "match UnwantedSpace /" .. unwanted_space_while_typing .. "/" })
autocmd("BufWinLeave", { callback = function() vim.fn.clearmatches() end })

-- open the results after :grep, as :Ack did
autocmd("QuickFixCmdPost", { pattern = "grep", command = "cwindow" })

autocmd("BufWritePost", { pattern = vim.env.MYVIMRC, command = "source <afile>" })

autocmd("FileType", {
  pattern = "erlang",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- .amt files only borrow Erlang's colors: switching their filetype would also attach the Erlang LSP
autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.amt", command = "setlocal syntax=erlang" })

-- Neovim already detects .eex/.leex (eelixir), .heex and .sface (surface)
vim.filetype.add({
  extension = { lexs = "eelixir" },
  filename = { ["mix.lock"] = "elixir" },
})

------------------------------------------------------------------------------------------------
-- Plugins (vim.pack, built into Neovim 0.12: :lua vim.pack.update() to update)
------------------------------------------------------------------------------------------------

local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({
  -- Vimscript plugins without a Neovim-native equivalent
  gh("tpope/vim-fugitive"),
  gh("tpope/vim-eunuch"),
  gh("tpope/vim-abolish"),
  gh("tpope/vim-obsession"),
  gh("EinfachToll/DidYouMean"),
  gh("godlygeek/tabular"),
  gh("dhruvasagar/vim-table-mode"),
  gh("darfink/vim-plist"),
  gh("aklt/plantuml-syntax"),

  gh("nvim-treesitter/nvim-treesitter"),
  gh("neovim/nvim-lspconfig"),
  gh("stevearc/conform.nvim"),

  gh("nvim-lua/plenary.nvim"), -- required by telescope
  gh("nvim-telescope/telescope.nvim"),
  gh("stevearc/oil.nvim"),
  gh("refractalize/oil-git-status.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("nvim-lualine/lualine.nvim"),

  gh("kylechui/nvim-surround"),
  gh("windwp/nvim-autopairs"),
  gh("nvim-mini/mini.move"),
  gh("gbprod/yanky.nvim"),
  { src = gh("jake-stewart/multicursor.nvim"), version = "1.0" },
  gh("folke/zen-mode.nvim"),
  gh("folke/twilight.nvim"),
  gh("MeanderingProgrammer/render-markdown.nvim"),

  gh("tetzng/random-colorscheme.nvim"),
  gh("itsfernn/auto-gnome-theme.nvim"),
  gh("folke/tokyonight.nvim"),
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
})

------------------------------------------------------------------------------------------------
-- Colorschemes: tokyonight, tokyonight-{night,storm,moon,day}, base16-*, PaperColorSlim,
-- PaperColorSlimLight, hybrid, everforest, edge, catppuccin-{latte,frappe,macchiato,mocha}
------------------------------------------------------------------------------------------------

require("tokyonight").setup({ style = "night" }) -- tokyonight-vim's dark style
-- require("tokyonight").setup({ style = "day" }) -- tokyonight-vim's light tyle
-- loaded before the plugin setups: some (zen-mode) derive their colors from it at setup time
-- vim.cmd.colorscheme("tokyonight")

-- require('random-colorscheme').set({'rose-pine-dawn', 'tokyonight-day', 'catppuccin-latte'})
-- themed-term picks the colorscheme so that nvim matches its terminal's palette
if vim.env.NVIM_COLORSCHEME then
  vim.cmd.colorscheme(vim.env.NVIM_COLORSCHEME)
else
  require('random-colorscheme').set({'rose-pine-moon', 'tokyonight-night', 'catppuccin-mocha'})
end

-- if not vim.g.auto_gnome_theme_started then
--   require("auto-gnome-theme").setup({
--     -- See Configuration section below
--     theme = "tokyonight"
--     -- dark_theme = "tokyonight",
--     -- light_theme = "rose-pine",
--   })
--   vim.g.auto_gnome_theme_started = true
-- end

-- Treesitter: highlighting for every filetype that has a parser; replaces vim-elixir, vimerl and
-- vim-ansible-yaml. Parsers are built on first start (needs tree-sitter-cli and a C compiler);
-- Neovim itself ships c, lua, markdown, vim and vimdoc.
require("nvim-treesitter").install({
  "bash", "css", "diff", "eex", "elixir", "erlang", "git_rebase", "gitcommit", "heex", "html",
  "javascript", "json", "surface", "yaml",
})
autocmd("FileType", { callback = function(args) pcall(vim.treesitter.start, args.buf) end })

local telescope = require("telescope.builtin")
map("n", "<C-p>", telescope.find_files)
map("n", "<C-t>", telescope.buffers)
map("n", "<leader>g", telescope.live_grep) -- fzf.vim's :Rg

local oil = require("oil")
oil.setup({ win_options = { signcolumn = "yes:2" } }) -- room for oil-git-status
require("oil-git-status").setup()
map({ "n", "v", "o" }, "<A-n>", function()
  if vim.bo.filetype == "oil" then oil.close() else oil.open() end
end)

require("gitsigns").setup()

require("lualine").setup({
  options = { theme = "wombat", icons_enabled = false, section_separators = "", component_separators = "|" },
  sections = { lualine_b = { "branch" }, lualine_c = { "filename" } },
})

require("nvim-surround").setup()

local autopairs = require("nvim-autopairs")
autopairs.setup()
-- replaces vim-endwise: `end` after `do`/`fn` (Elixir) and `then`/`function` (Lua)
autopairs.add_rules(require("nvim-autopairs.rules.endwise-elixir"))
autopairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))

require("mini.move").setup() -- <A-h/j/k/l> move the line or selection, as vim-move did

require("yanky").setup()
map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
-- after a put, cycle through the yank history (vim-yankstack's keys)
map("n", "<M-p>", "<Plug>(YankyPreviousEntry)")
map("n", "<M-P>", "<Plug>(YankyNextEntry)")

-- vim-multiple-cursors' keys: <C-n> adds a cursor on the next match; while several cursors exist,
-- <C-x> skips a match, <C-p> removes the last cursor and <Esc> leaves
-- setup() wraps vim.api.nvim_feedkeys; re-running it on re-source wraps the wrapper, which then
-- tail-calls itself forever
local mc = require("multicursor-nvim")
if not vim.g.multicursor_setup_done then
  mc.setup()
  vim.g.multicursor_setup_done = true
end


map({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end)
mc.addKeymapLayer(function(layer_map)
  layer_map({ "n", "x" }, "<C-x>", function() mc.matchSkipCursor(1) end)
  layer_map({ "n", "x" }, "<C-p>", mc.deleteCursor)
  layer_map("n", "<Esc>", mc.clearCursors)
end)

-- focus tools
require("zen-mode").setup({
  window = {
    backdrop = 1, -- same background as the editor, like Goyo
    height = 0.85, -- Goyo's default
    options = { number = false, signcolumn = "no" },
  },
})
require("twilight").setup()

-- rendered in the buffer instead of a browser; off by default like instant_markdown_autostart = 0,
-- toggle it with :RenderMarkdown toggle
require("render-markdown").setup({ enabled = false })

-- replaces ALE's mix_format fixer (:ALEFix)
require("conform").setup({ formatters_by_ft = { elixir = { "mix" } } })
vim.api.nvim_create_user_command("Format", function() require("conform").format() end, {})

-- only start the servers that are actually installed, so a missing one doesn't error on every file
for _, server in ipairs({ "expert", "elixirls", "clangd", "elp" }) do
  local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
  local installed = type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1
  if installed then vim.lsp.enable(server) end
end

opt.completeopt = { "menuone", "noinsert", "popup" }

autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
