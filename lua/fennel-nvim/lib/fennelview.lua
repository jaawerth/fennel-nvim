local function view_quote(str)
  return ("\"" .. str:gsub("\"", "\\\"") .. "\"")
end
require("fennel").metadata:setall(view_quote, "fnl/arglist", {"str"})
local short_control_char_escapes = {["\11"] = "\\v", ["\12"] = "\\f", ["\13"] = "\\r", ["\7"] = "\\a", ["\8"] = "\\b", ["\9"] = "\\t", ["\n"] = "\\n"}
local long_control_char_escapes = nil
do
  local long = {}
  for i = 0, 31 do
    local ch = string.char(i)
    if not short_control_char_escapes[ch] then
      short_control_char_escapes[ch] = ("\\" .. i)
      long[ch] = ("\\%03d"):format(i)
    end
  end
  long_control_char_escapes = long
end
local function escape(str)
  local str0 = str:gsub("\\", "\\\\")
  local str1 = str0:gsub("(%c)%f[0-9]", long_control_char_escapes)
  return str1:gsub("%c", short_control_char_escapes)
end
require("fennel").metadata:setall(escape, "fnl/arglist", {"str"})
local function sequence_key_3f(k, len)
  return ((type(k) == "number") and (1 <= k) and (k <= len) and (math.floor(k) == k))
end
require("fennel").metadata:setall(sequence_key_3f, "fnl/arglist", {"k", "len"})
local type_order = {["function"] = 5, boolean = 2, number = 1, string = 3, table = 4, thread = 7, userdata = 6}
local function sort_keys(a, b)
  local ta = type(a)
  local tb = type(b)
  if ((ta == tb) and (ta ~= "boolean") and ((ta == "string") or (ta == "number"))) then
    return (a < b)
  else
    local dta = type_order[a]
    local dtb = type_order[b]
    if (dta and dtb) then
      return (dta < dtb)
    elseif dta then
      return true
    elseif dtb then
      return false
    elseif "else" then
      return (ta < tb)
    end
  end
end
require("fennel").metadata:setall(sort_keys, "fnl/arglist", {"a", "b"})
local function get_sequence_length(t)
  local len = 1
  for i in ipairs(t) do
    len = i
  end
  return len
end
require("fennel").metadata:setall(get_sequence_length, "fnl/arglist", {"t"})
local function get_nonsequential_keys(t)
  local keys = {}
  local sequence_length = get_sequence_length(t)
  for k in pairs(t) do
    if not sequence_key_3f(k, sequence_length) then
      table.insert(keys, k)
    end
  end
  table.sort(keys, sort_keys)
  return keys, sequence_length
end
require("fennel").metadata:setall(get_nonsequential_keys, "fnl/arglist", {"t"})
local function count_table_appearances(t, appearances)
  if (type(t) == "table") then
    if not appearances[t] then
      appearances[t] = 1
      for k, v in pairs(t) do
        count_table_appearances(k, appearances)
        count_table_appearances(v, appearances)
      end
    end
  else
    if (t and (t == t)) then
      appearances[t] = ((appearances[t] or 0) + 1)
    end
  end
  return appearances
end
require("fennel").metadata:setall(count_table_appearances, "fnl/arglist", {"t", "appearances"})
local put_value = nil
local function puts(self, ...)
  for _, v in ipairs({...}) do
    table.insert(self.buffer, v)
  end
  return nil
end
require("fennel").metadata:setall(puts, "fnl/arglist", {"self", "..."})
local function tabify(self)
  return puts(self, "\n", (self.indent):rep(self.level))
end
require("fennel").metadata:setall(tabify, "fnl/arglist", {"self"})
local function already_visited_3f(self, v)
  return (self.ids[v] ~= nil)
end
require("fennel").metadata:setall(already_visited_3f, "fnl/arglist", {"self", "v"})
local function get_id(self, v)
  local id = self.ids[v]
  if not id then
    local tv = type(v)
    id = ((self["max-ids"][tv] or 0) + 1)
    self["max-ids"][tv] = id
    self.ids[v] = id
  end
  return tostring(id)
end
require("fennel").metadata:setall(get_id, "fnl/arglist", {"self", "v"})
local function put_sequential_table(self, t, len)
  puts(self, "[")
  self.level = (self.level + 1)
  for i = 1, len do
    puts(self, " ")
    put_value(self, t[i])
  end
  self.level = (self.level - 1)
  return puts(self, " ]")
end
require("fennel").metadata:setall(put_sequential_table, "fnl/arglist", {"self", "t", "len"})
local function put_key(self, k)
  if ((type(k) == "string") and k:find("^[-%w?\\^_!$%&*+./@:|<=>]+$")) then
    return puts(self, ":", k)
  else
    return put_value(self, k)
  end
end
require("fennel").metadata:setall(put_key, "fnl/arglist", {"self", "k"})
local function put_kv_table(self, t, ordered_keys)
  puts(self, "{")
  self.level = (self.level + 1)
  for _, k in ipairs(ordered_keys) do
    tabify(self)
    put_key(self, k)
    puts(self, " ")
    put_value(self, t[k])
  end
  for i, v in ipairs(t) do
    tabify(self)
    put_key(self, i)
    puts(self, " ")
    put_value(self, v)
  end
  self.level = (self.level - 1)
  tabify(self)
  return puts(self, "}")
end
require("fennel").metadata:setall(put_kv_table, "fnl/arglist", {"self", "t", "ordered-keys"})
local function put_table(self, t)
  if (already_visited_3f(self, t) and self["detect-cycles?"]) then
    return puts(self, "#<table ", get_id(self, t), ">")
  elseif (self.level >= self.depth) then
    return puts(self, "{...}")
  elseif "else" then
    local non_seq_keys, len = get_nonsequential_keys(t)
    local id = get_id(self, t)
    if ((1 < (self.appearances[t] or 0)) and self["detect-cycles?"]) then
      return puts(self, "#<table", id, ">")
    elseif ((#non_seq_keys == 0) and (#t == 0)) then
      return puts(self, "{}")
    elseif (#non_seq_keys == 0) then
      return put_sequential_table(self, t, len)
    elseif "else" then
      return put_kv_table(self, t, non_seq_keys)
    end
  end
end
require("fennel").metadata:setall(put_table, "fnl/arglist", {"self", "t"})
local function _0_(self, v)
  local tv = type(v)
  if (tv == "string") then
    return puts(self, view_quote(escape(v)))
  elseif ((tv == "number") or (tv == "boolean") or (tv == "nil")) then
    return puts(self, tostring(v))
  elseif (tv == "table") then
    return put_table(self, v)
  elseif "else" then
    return puts(self, "#<", tostring(v), ">")
  end
end
require("fennel").metadata:setall(_0_, "fnl/arglist", {"self", "v"})
put_value = _0_
local function one_line(str)
  local ret = str:gsub("\n", " "):gsub("%[ ", "["):gsub(" %]", "]"):gsub("%{ ", "{"):gsub(" %}", "}"):gsub("%( ", "("):gsub(" %)", ")")
  return ret
end
require("fennel").metadata:setall(one_line, "fnl/arglist", {"str"})
local function fennelview(x, options)
  local options0 = (options or {})
  local inspector = nil
  local function _1_()
    if options0["one-line"] then
      return ""
    else
      return "  "
    end
  end
  inspector = {["detect-cycles?"] = not (false == options0["detect-cycles?"]), ["max-ids"] = {}, appearances = count_table_appearances(x, {}), buffer = {}, depth = (options0.depth or 128), ids = {}, indent = (options0.indent or _1_()), level = 0}
  put_value(inspector, x)
  do
    local str = table.concat(inspector.buffer)
    if options0["one-line"] then
      return one_line(str)
    else
      return str
    end
  end
end
require("fennel").metadata:setall(fennelview, "fnl/arglist", {"x", "options"}, "fnl/docstring", "Return a string representation of x.")
return fennelview
