local gsub = string.gsub
local function default_path_transform(p)
  return gsub(gsub(p, "(%/)lua(%/%?.*%.)lua$", "%1fnl%2fnl"), "%.lua$", ".fnl")
end
require("fennel").metadata:setall(default_path_transform, "fnl/arglist", {"p"})
local function initialize(cfg, _3ftransform)
  assert((nil ~= cfg), ("Missing argument %s on %s:%s"):format("cfg", "fnl/fennel-nvim/update-fennel-paths.fnl", 6))
  if not _3ftransform then
    _3ftransform = default_path_transform
  end
  local prev_pkg_path, prev_pkg_path_set = nil, {}
  local function update_fennel_paths()
    if not cfg.settings.sync_fennel_path then
      return
    end
    local _2_ = {{}, {}}
    local new = _2_[1]
    local new_pkg_path_set = _2_[2]
    for path in string.gmatch((package.path .. ";"), "([^;]*);") do
      local fnl_path = _3ftransform(path)
      new_pkg_path_set[fnl_path] = true
      new[(#new + 1)] = fnl_path
    end
    for path0 in string.gmatch((fennel.path .. ";" .. "([^;]*);")) do
      if not (new_pkg_path_set[path0] or prev_pkg_path_set[path0]) then
        table.insert(new, path0)
      end
    end
    prev_pkg_path = package.path
    prev_pkg_path_set = new_pkg_path_set
    fennel.path = table.concat(new, ";")
    return nil
  end
  require("fennel").metadata:setall(update_fennel_paths, "fnl/arglist", {}, "fnl/docstring", "Synchronize fennel.path from package.path, using the configured transform")
  return update_fennel_paths
end
require("fennel").metadata:setall(initialize, "fnl/arglist", {"cfg", "?transform"}, "fnl/docstring", "initialize fennel.path synchronizer")
return initialize
