local fennel = require("fennel-nvim").fennel
local function _2aget_specials(env)
  local function _0_()
    if env then
      return {{env = env}}
    else
      return {}
    end
  end
  return fennel.eval("(macro list-specials {}\n                  (local specials {})\n                  (each [k (pairs _SPECIALS)] (tset specials k true)) specials)\n                (list-specials)", unpack(_0_()))
end
require("fennel").metadata:setall(_2aget_specials, "fnl/arglist", {"env"})
local specials = _2aget_specials()
local _2alimit_2a = 400
local function set_limit(n)
  assert((type(n) == "number"), "n must be a number.")
  _2alimit_2a = n
  return nil
end
require("fennel").metadata:setall(set_limit, "fnl/arglist", {"n"}, "fnl/docstring", "Sets default matches limit to n. Pass math.huge or (/ 1 0) for no limit")
local function complete(text, limit, lua_only_3f)
  local limit0 = (limit or _2alimit_2a)
  local matches = {}
  local function add_partials(input, tbl, prefix)
    local key = next(tbl)
    while (key and (limit0 > #matches)) do
      if (input == key:sub(1, #input)) then
        table.insert(matches, (prefix .. key))
      end
      key = next(tbl, key)
    end
    return key
  end
  require("fennel").metadata:setall(add_partials, "fnl/arglist", {"input", "tbl", "prefix"})
  local function add_matches(input, tbl, prefix)
    local prefix0 = nil
    if prefix then
      prefix0 = (prefix .. ".")
    else
      prefix0 = ""
    end
    if string.find(input, "%.") then
      local head, tail = input:match("^([^.]+)%.(.*)")
      local tbl_head = tbl[head]
      if ("table" == type(tbl_head)) then
        return add_matches(tail, tbl_head, (prefix0 .. head))
      end
    else
      return add_partials(input, tbl, prefix0)
    end
  end
  require("fennel").metadata:setall(add_matches, "fnl/arglist", {"input", "tbl", "prefix"})
  if not lua_only_3f then
    add_matches(text, specials)
  end
  add_matches(text, (_G or {}))
  return matches
end
require("fennel").metadata:setall(complete, "fnl/arglist", {"text", "limit", "lua-only?"}, "fnl/docstring", "Match supplied text against all globals and (unless disabled) Fennel specials/macros.\nDefault limit is 400 but can be changed with set-limit.")
local function find_start()
  local _0_ = vim.api.nvim_win_get_cursor(0)
  local row = _0_[1]
  local col = _0_[2]
  local _1_ = vim.api.nvim_buf_get_lines(".", (row - 1), row, true)
  local line = _1_[1]
  local _2_ = {col, nil}
  local i = _2_[1]
  local found = _2_[2]
  while (not found and (i > 0)) do
    if string.find(line:sub(i, i), "[()%s%#]") then
      found = true
    else
      i = (i - 1)
    end
  end
  if (i >= 0) then
    return i, line:sub((i + 1), col)
  else
    return i
  end
end
require("fennel").metadata:setall(find_start, "fnl/arglist", {}, "fnl/docstring", "Used by (n)vim omnifunc. Uses cursor position to find completion starting\npoint, returning (values start text-to-match).")
local function gen_omnifunc(lua_only_3f)
  local function omnifunc(fs, input)
    if (1 == fs) then
      return find_start()
    else
      local _0_
      if ("" ~= input) then
        _0_ = input
      else
        _0_ = select(2, find_start())
      end
      return complete(_0_, nil, lua_only_3f)
    end
  end
  require("fennel").metadata:setall(omnifunc, "fnl/arglist", {"fs", "input"}, "fnl/docstring", "Wrapped by viml to set 'omnifunc'. See `:help complete-functions`")
  return omnifunc
end
require("fennel").metadata:setall(gen_omnifunc, "fnl/arglist", {"lua-only?"}, "fnl/docstring", "Generate an omnifunc to be used from viml. See `:h omnifunc` `:h complete-functions`")
return {["find-start"] = find_start, ["fnl-omnifunc"] = gen_omnifunc(), ["gen-omnifunc"] = gen_omnifunc, ["get-specials"] = _2aget_specials, ["lua-omnifunc"] = gen_omnifunc(true), ["set-limit"] = set_limit, complete = complete}
