-- PhantOS: a plain Neovim that opens fast under iSH's emulator. No plugin manager.

-- Cache compiled Lua, so startup doesn't parse the runtime each time.
vim.loader.enable()

-- Providers Neovim would probe for at startup; none of them are installed.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Built-in plugins a phone terminal rarely needs; netrw stays as the file browser.
for _, plugin in ipairs({ 'gzip', 'tar', 'tarPlugin', 'zip', 'zipPlugin', 'tutor', 'tohtml', 'spellfile_plugin' }) do
  vim.g['loaded_' .. plugin] = 1
end

-- Yank and paste go through the iOS clipboard, which iSH exposes as /dev/clipboard.
vim.g.clipboard = {
  name = 'ios',
  copy = { ['+'] = { 'sh', '-c', 'cat > /dev/clipboard' }, ['*'] = { 'sh', '-c', 'cat > /dev/clipboard' } },
  paste = { ['+'] = { 'cat', '/dev/clipboard' }, ['*'] = { 'cat', '/dev/clipboard' } },
  cache_enabled = 0,
}
vim.o.clipboard = 'unnamedplus'

vim.o.number = true
vim.o.mouse = 'a'
vim.o.termguicolors = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.scrolloff = 4

pcall(vim.cmd.colorscheme, 'habamax')
