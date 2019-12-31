local function _0_()
  return require("fennel-nvim.lib.fennel")
end
package.preload.fennel = (package.preload.fennel or _0_)
local function _1_()
  return require("fennel-nvim.lib.fennelview")
end
package.preload.fennelview = (package.preload.fennelview or _1_)
local api = vim.api
local fennel = require("fennel")
local view = require("fennelview")
local loaders = require("fennel-nvim.patch-loaders")
local compat = require("fennel-nvim.vim-compat")
local utils = require("fennel-nvim.utils")
local _2_ = utils
local assoc_in = _2_["assoc-in"]
local assign = _2_["assign"]
local nil_wrap = _2_["nil-wrap"]
local _3_ = compat.api
local buf_get_lines = _3_["buf-get-lines"]
local buf_set_lines = _3_["buf-set-lines"]
local fnl = {settings = {auto_init = true, defaults = {compile = {}, dofile = {env = _G, useMetadata = true}, eval = {env = _G, useMetadata = true}, searcher = {env = _G, useMetadata = true}}, sync_fennel_paths = true}}
fnl._update_fennel_paths = function()
  fnl._update_fennel_paths = require("fennel-nvim.update-fennel-paths")(fnl)
  return fnl._update_fennel_paths()
end
require("fennel").metadata:setall(fnl._update_fennel_paths, "fnl/arglist", {}, "fnl/docstring", "Updates fennel.path to keep it in sync with changes to package.path")
fnl.eval = function(code, _3fargs, _3foptions)
  assert((nil ~= code), ("Missing argument %s on %s:%s"):format("code", "fnl/fennel-nvim/init.fnl", 31))
  fnl._update_fennel_paths()
  if not _3foptions then
    _3foptions = {}
  end
  do
    local opts = assign({}, (fnl.settings.defaults.eval or {}), (_3foptions or {}))
    local env = (opts.env or {})
    opts.env = assign({}, env, {_A = _3fargs})
    return fennel.eval(code, opts)
  end
end
require("fennel").metadata:setall(fnl.eval, "fnl/arglist", {"code", "?args", "?options"}, "fnl/docstring", "Like luaeval, for fennel. Evaluates provided code, interpolating argument\nas _A. Unlike luaeval, takes an optional `options` argument for overriding\nthe default options to fennel.eval.")
fnl.dofile = function(file, _3foptons)
  assert((nil ~= file), ("Missing argument %s on %s:%s"):format("file", "fnl/fennel-nvim/init.fnl", 44))
  fnl._update_fennel_paths()
  return fennel.dofile(file, assign({}, fnl.settings.defaults.dofile, __fnl_global___3foptions))
end
require("fennel").metadata:setall(fnl.dofile, "fnl/arglist", {"file", "?optons"}, "fnl/docstring", "Analog to `luafile` (see `:help luafile`). Accepts a table of Fennel\ncompiler options as optional second argument.")
fnl.dolines = function(expr, s, e)
  assert((nil ~= e), ("Missing argument %s on %s:%s"):format("e", "fnl/fennel-nvim/init.fnl", 51))
  assert((nil ~= s), ("Missing argument %s on %s:%s"):format("s", "fnl/fennel-nvim/init.fnl", 51))
  assert((nil ~= expr), ("Missing argument %s on %s:%s"):format("expr", "fnl/fennel-nvim/init.fnl", 51))
  fnl._update_fennel_paths()
  local nl, offset = {}, (1 - s)
  local func, lines = fnl.eval(("(fn [line linenr] " .. expr .. ")")), buf_get_lines(".", (s - 1), e, true)
  for i = 1, #lines do
    local new_line = func(lines[i], (i + s + -1))
    nl[1] = new_line
    if ("string" == type(new_line)) then
      buf_set_lines(".", (s + i + -1), (s + i), true, nl)
    end
  end
  return nil
end
require("fennel").metadata:setall(fnl.dolines, "fnl/arglist", {"expr", "s", "e"}, "fnl/docstring", "Analog to `luado` (see `:help luado`).")
fnl.compile = function(file, _3foptions)
  assert((nil ~= file), ("Missing argument %s on %s:%s"):format("file", "fnl/fennel-nvim/init.fnl", 64))
  fnl._update_fennel_paths()
  local _5_
  do
    local _4_0 = fnl.settings
    if _4_0 then
      local _6_0 = _4_0.defaults
      if _6_0 then
        _5_ = _6_0.compile
      else
        _5_ = _6_0
      end
    else
      _5_ = _4_0
    end
  end
  return fennel.compile(file, assign({}, _5_, _3foptions))
end
require("fennel").metadata:setall(fnl.compile, "fnl/arglist", {"file", "?options"})
fnl.patch_loaders = function(_3floader)
  return require("fennel-nvim.patch-loaders").patch((_3floader or fennel.makeSearcher(fnl.settings.defaults.searcher)))
end
require("fennel").metadata:setall(fnl.patch_loaders, "fnl/arglist", {"?loader"}, "fnl/docstring", "Inserts ?loader into package.loaders, replacing any previously\ninserted using this function. If no loader is provided, creates\none using (fennel.makeSearcher fnl.settings.defaults.searcher).")
do
  local _4_0 = fnl
  _4_0["vimdofile"] = nil_wrap(fnl.dofile)
  _4_0["vimeval"] = nil_wrap(fnl.eval)
  local function _5_()
    return error("This function has been renamed to patch_loaders")
  end
  _4_0["patchSearchers"] = _5_
  return _4_0
end
