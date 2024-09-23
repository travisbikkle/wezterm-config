local Config = require('config')

require('utils.backdrops'):set_files():random()

require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()

local wezterm = require 'wezterm'
local mux = wezterm.mux

local cache_dir = os.getenv('HOME') .. '/.config/wezterm/'
local window_size_cache_path = cache_dir .. 'window_size_cache.txt'

wezterm.on('gui-startup', function()
  os.execute('mkdir ' .. cache_dir)

  local window_size_cache_file = io.open(window_size_cache_path, 'r')
  if window_size_cache_file ~= nil then
    _, _, width, height = string.find(window_size_cache_file:read(), '(%d+),(%d+)')
    local tab, pane, window = mux.spawn_window{ width = tonumber(width), height = tonumber(height), position = {x=900, y=0} }
    window_size_cache_file:close()
    os.remove(window_size_cache_path)
  else
    local tab, pane, window = mux.spawn_window{}
    window:gui_window():maximize()
  end
end)

wezterm.on('window-resized', function(window, pane)
   local tab_size = pane:tab():get_size()
   cols = tab_size['cols']
   rows = tab_size['rows'] + 2 -- Without adding the 2 here, the window doesn't maximize
   contents = string.format('%d,%d', cols, rows)
   window_size_cache_file = assert(io.open(window_size_cache_path, 'w'))
   window_size_cache_file:write(contents)
   window_size_cache_file:close()
end)

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
