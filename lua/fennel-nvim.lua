local fennel = require('fennel')
local view = require('fennelview')

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

return {
  version = fennel.version,
  defaults = defaults,
  inherit = inherit,

  -- main api functions
  compile = function(file, opts)
    return fennel.compile(file, inherit(opts or {}, defaults.compile))
  end,

  eval = function(code, args, options)
    local opts = inherit(options or {}, defaults.eval)
    opts.env._A = args
    return fennel.eval(code, opts)
  end,

  dofile = function(file, opts)
    return fennel.dofile(file, inherit(opts or {}, defaults.dofile))
  end,

  -- to make require() from lua also search for fennel modules
  patch_searchers = function()
    local found = false
    for i, v in ipairs(package.loaders or package.searchers) do
      if v == fennel.searcher then found = true end
    end
    if not found then
      table.insert(package.loaders or package.searchers, fennel.searcher)
    end
  end
}
