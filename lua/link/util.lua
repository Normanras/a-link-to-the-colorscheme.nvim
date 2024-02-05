local util = {}
local theme = require("link.theme")

local set_hl = function(table)
    for group, conf in pairs(table) do
        vim.api.nvim_set_hl(0, group, conf)
    end
end

function util.load()
    vim.api.nvim_command("hi clear")
    vim.o.background = "dark"
    vim.o.termguicolors = true
    vim.g.colors_name = "link"

    local coc = theme.loadCoc()
    local custom = theme.loadCustom()
    local lsp = theme.loadLsp()
    local plugins = theme.loadPlugins()
    local syntax = theme.loadSyntax()
    local treesitter = theme.loadTreesitter()
    local ui = theme.loadUi()

    set_hl(syntax)
    set_hl(ui)
    set_hl(treesitter)
    set_hl(coc)
    set_hl(lsp)
    set_hl(custom)
    set_hl(plugins)
    theme.loadTerminal()
end

---@param config Config
function util.autocmds(config)
  local group = vim.api.nvim_create_augroup("link", { clear = true })

    vim.api.nvim_create_autocmd("ColorSchemePre", {
    group = group,
    callback = function()
      vim.api.nvim_del_augroup_by_id(group)
    end,
  })
  local function set_whl()
    local win = vim.api.nvim_get_current_win()
    local whl = vim.split(vim.wo[win].winhighlight, ",")
    vim.list_extend(whl, { "Normal:NormalSB", "SignColumn:SignColumnSB" })
    whl = vim.tbl_filter(function(hl)
      return hl ~= ""
    end, whl)
    vim.opt_local.winhighlight = table.concat(whl, ",")
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = table.concat(config.sidebars, ","),
    callback = set_whl,
  })
  if vim.tbl_contains(config.sidebars, "terminal") then
    vim.api.nvim_create_autocmd("TermOpen", {
      group = group,
      callback = set_whl,
    })
  end
end

---@param theme Theme
function util.load(theme)
  -- only needed to clear when not the default colorscheme
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "link"

  util.autocmds(theme.config)

end


return util
