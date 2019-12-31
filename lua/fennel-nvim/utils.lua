local function assign(tgt, src, ...)
  if ("table" == type(src)) then
    for k, v in pairs(src) do
      tgt[k] = v
    end
  end
  if (select("#", ...) == 0) then
    return tgt
  else
    return assign(tgt, ...)
  end
end
require("fennel").metadata:setall(assign, "fnl/arglist", {"tgt", "src", "..."}, "fnl/docstring", "Merged all supplies pairs tables into tgt table, and returns tgt.")
local function copy(orig)
  if ("table" ~= type(orig)) then
    return orig
  else
    return assign({}, orig)
  end
end
require("fennel").metadata:setall(copy, "fnl/arglist", {"orig"})
local function _2adeep_copy(seen, orig)
  if ("table" ~= type(orig)) then
    return orig
  else
    if (nil ~= seen[orig]) then
      return seen[orig]
    else
      local copy0 = {}
      for o_key, o_val in pairs(orig) do
        copy0[_2adeep_copy(seen, o_key)] = _2adeep_copy(seen, o_val)
      end
      seen[orig] = copy0
      return copy0
    end
  end
end
require("fennel").metadata:setall(_2adeep_copy, "fnl/arglist", {"seen", "orig"})
local function deep_copy(orig)
  return _2adeep_copy({}, orig)
end
require("fennel").metadata:setall(deep_copy, "fnl/arglist", {"orig"})
local function get_in(col, path, _3fnf)
  assert((nil ~= path), ("Missing argument %s on %s:%s"):format("path", "fnl/fennel-nvim/utils.fnl", 27))
  assert((nil ~= col), ("Missing argument %s on %s:%s"):format("col", "fnl/fennel-nvim/utils.fnl", 27))
  local tgt = col
  local len = #path
  for i = 1, len do
    local _0_0, _1_0, _2_0 = tgt
    if ((type(_0_0) == "table") and (nil ~= _0_0[path[i]])) then
      local val = _0_0[path[i]]
      tgt = val
    else
      local _ = _0_0
      do
        tgt = _3fnf
        break
      end
    end
  end
  return tgt
end
require("fennel").metadata:setall(get_in, "fnl/arglist", {"col", "path", "?nf"})
local function get(tgt, key, _3fnot_found)
  assert((nil ~= key), ("Missing argument %s on %s:%s"):format("key", "fnl/fennel-nvim/utils.fnl", 36))
  assert((nil ~= tgt), ("Missing argument %s on %s:%s"):format("tgt", "fnl/fennel-nvim/utils.fnl", 36))
  do
    local _0_0 = tgt
    if ((type(_0_0) == "table") and (nil ~= _0_0[key])) then
      local v = _0_0[key]
      return v
    else
      local _ = _0_0
      return _3fnot_found
    end
  end
end
require("fennel").metadata:setall(get, "fnl/arglist", {"tgt", "key", "?not-found"})
local function assoc_in(tgt, path, _3fvalue)
  assert((nil ~= path), ("Missing argument %s on %s:%s"):format("path", "fnl/fennel-nvim/utils.fnl", 39))
  assert((nil ~= tgt), ("Missing argument %s on %s:%s"):format("tgt", "fnl/fennel-nvim/utils.fnl", 39))
  assert(("table" == type(tgt)), "Assoc-in requires tgt to be a table.")
  assert((("table" == type(path)) and (0 < #path)), "Assoc-in expects path to be a table of length > 0")
  local result, _end = assign({}, tgt), #path
  local function recur(parent, i)
    local done_3f = (i == _end)
    local key = path[i]
    local new_child = nil
    if done_3f then
      new_child = _3fvalue
    elseif ("table" == type(parent[key])) then
      new_child = assign({}, parent[key])
    else
      new_child = {}
    end
    parent[key] = new_child
    if done_3f then
      return result
    else
      return recur(new_child, (i + 1))
    end
  end
  require("fennel").metadata:setall(recur, "fnl/arglist", {"parent", "i"})
  return pcall(recur, result, 1)
end
require("fennel").metadata:setall(assoc_in, "fnl/arglist", {"tgt", "path", "?value"})
local function lazy_table(base_table, lazy_props, loader)
  local loader0 = (loader or dofile)
  local function _0_(tgt, key)
    local getter = lazy_props[key]
    if (nil == getter) then
    elseif (type(getter) == "function") then
      tgt[key] = getter(tgt, key)
    else
      tgt[key] = loader0(getter)
    end
    return tgt[key]
  end
  require("fennel").metadata:setall(_0_, "fnl/arglist", {"tgt", "key"})
  return setmetatable(base_table, {__index = _0_})
end
require("fennel").metadata:setall(lazy_table, "fnl/arglist", {"base-table", "lazy-props", "loader"})
local function inherit(t, index, extra_mt_opts)
  assert((nil ~= extra_mt_opts), ("Missing argument %s on %s:%s"):format("extra-mt-opts", "fnl/fennel-nvim/utils.fnl", 66))
  assert((nil ~= index), ("Missing argument %s on %s:%s"):format("index", "fnl/fennel-nvim/utils.fnl", 66))
  assert((nil ~= t), ("Missing argument %s on %s:%s"):format("t", "fnl/fennel-nvim/utils.fnl", 66))
  local mt = assign({}, extra_mt_opts)
  mt["__index"] = (index or {})
  return setmetatable(t, mt)
end
require("fennel").metadata:setall(inherit, "fnl/arglist", {"t", "index", "extra-mt-opts"})
local function nil_wrap(f)
  local function nil_wrapped(...)
    f(...)
    return nil
  end
  require("fennel").metadata:setall(nil_wrapped, "fnl/arglist", {"..."})
  return nil_wrapped
end
require("fennel").metadata:setall(nil_wrap, "fnl/arglist", {"f"}, "fnl/docstring", "wraps function, f, so it always returns nil.")
return {["assoc-in"] = assoc_in, ["lazy-table"] = lazy_table, ["nil-wrap"] = nil_wrap, assign = assign, copy = copy, get = get, inherit = inherit}
