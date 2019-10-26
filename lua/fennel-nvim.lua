local fennel = require('fennel')
local view = require('fennelview')
local isNvim = vim.api and vim.api.nvim_get_var ~= nil
local function inherit(t, index, metatable)
  local mt = type(metatable) == "table" and metatable or {}
  mt.__index = index or {}
  return setmetatable(t, mt)
end

-- set up default environment for eval/dofile by inheriting from global
local env = inherit({ fennel = fennel, view = view }, _ENV or _G)

local allowedGlobals = {'_A', 'view', 'fennel'}
for k in pairs(_ENV or _G) do table.insert(allowedGlobals, k) end

local defaults = {
  compile = {},
  eval = { useMetadata = true, env = env, allowedGlobals = false },
  dofile = { useMetadata = true, env = env, allowedGlobals = false },
}

-- wrap a function to make it safe for viml interop
local function vimWrap(func)
  return function(...)
    local ret = func(...)
    local retType = type(ret)
    if retType == "function" then
      return nil
    elseif retType == "table" then
      local mt = getmetatable(ret) or {}
      if mt.__call then return nil else return ret end
    else
      return ret
    end
  end
end

local _updateFennelPaths
local function fnlEval(code, args, options)
  _updateFennelPaths()
  local opts = inherit(options or {}, defaults.eval)
  opts.env._A = args
  return fennel.eval(code, opts)
end
local function fnlDoFile(file, opts)
  _updateFennelPaths()
  return fennel.dofile(file, inherit(opts or defaults.dofile))
end
local function fnlDo(expr, s, e)
  local func = fnlEval(string.format('(fn [line linenr] %s)', expr))
  local lines = isNvim and vim.api.nvim_buf_get_lines('.', s - 1, e, true) or vim.buffer()
  local lineOffset = isNvim and 1 - s or 0
  for i = s, e do func(lines[i + lineOffset], i) end
end

local module = {
  fennel = fennel,
  defaults = defaults,
  inherit = inherit,

  -- main api functions
  eval = fnlEval,
  vimeval = vimWrap(fnlEval), -- version with returns safe for viml interop
  dofile = fnlDoFile,
  dolines = fnlDo,
  vimdofile = vimWrap(fnlDoFile), -- version with returns safe for viml interop
  compile = function(file, opts)
    _updateFennelPaths()
    return fennel.compile(file, inherit(opts or {}, defaults.compile))
  end,

  -- to make require() from lua also search for fennel modules
  patchSearchers = function()
    local found = false
    for _, v in ipairs(package.loaders or package.searchers) do
      if v == fennel.searcher then found = true end
    end
    if not found then
      table.insert(package.loaders or package.searchers, fennel.searcher)
    end
  end,
  syncFennelPath = true,
}
local originalFennelPath = fennel.path
module.resetFennelPath = function()
  fennel.path = originalFennelPath
end

local prevPkgPath
local prevPkgPathSet = {}
_updateFennelPaths = function()
  if not module.syncFennelPath or prevPkgPath == package.path then
      return nil
  end
  local new, newPkgPathSet = {}, {}
  -- append ; for simple pattern that includes empty path ";;" (default path)
  -- this matches how neovim does it in _udpate_package_paths
  for p in string.gmatch(package.path .. ';', "([^;]*);") do
    local fnlPath = p:gsub("(%/)lua(%/%?.*%.)lua$", "%1fnl%2fnl")
                     :gsub("%.lua$", ".fnl")
    newPkgPathSet[fnlPath] = true
    new[#new + 1] = fnlPath
  end
  for p in string.gmatch(fennel.path .. ';', "([^;]*);") do
    if not (newPkgPathSet[p] or prevPkgPathSet[p]) then
      new[#new + 1] = p
    end
  end
  prevPkgPath = package.path
  prevPkgPathSet = newPkgPathSet
  fennel.path = table.concat(new, ';')
end
_updateFennelPaths()

return module
