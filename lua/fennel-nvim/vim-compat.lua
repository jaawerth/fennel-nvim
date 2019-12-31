local vim = _G.vim
local nvim_call = (vim and vim.api and vim.api.nvim_call_function)
local is_nvim = nil
do
  local ok, res = pcall(nvim_call, "has", {"nvim"})
  is_nvim = (ok and (res == 1))
end
local api, shim_targets = {}, {"buf_set_lines", "buf_get_lines"}
local function _0_(...)
  if is_nvim then
    for _, k in ipairs(shim_targets) do
      api[k:gsub("_", "-")] = vim.api[("nvim_" .. k)]
    end
    return nil
  else
    api["buf-get-lines"] = function(bufnr, start, _end, strict_3f)
      assert((nil ~= strict_3f), ("Missing argument %s on %s:%s"):format("strict?", "fnl/fennel-nvim/vim-compat.fnl", 15))
      assert((nil ~= _end), ("Missing argument %s on %s:%s"):format("end", "fnl/fennel-nvim/vim-compat.fnl", 15))
      assert((nil ~= start), ("Missing argument %s on %s:%s"):format("start", "fnl/fennel-nvim/vim-compat.fnl", 15))
      assert((nil ~= bufnr), ("Missing argument %s on %s:%s"):format("bufnr", "fnl/fennel-nvim/vim-compat.fnl", 15))
      do
        local buf = vim.buffer(bufnr)
        local b_len = #buf
        local s = nil
        local function _0_()
          if (0 < start) then
            return (start + b_len + 1)
          else
            return start
          end
        end
        s = (1 + _0_())
        local e = nil
        local function _1_()
          if (0 < _end) then
            return (_end + b_len + 1)
          else
            return _end
          end
        end
        e = (1 + _1_())
        local lines = {}
        if strict_3f then
          assert(((0 <= s) and (b_len >= s) and (0 <= e) and (b_len >= e)), "Index out of bounds")
        else
          s, e = math.min((1 + b_len), math.max(1, s)), math.min((1 + b_len), math.max(1, e))
        end
        for i = (s - 1), e do
          lines[(#lines + 1)] = buf[(i + 1)]
        end
        return lines
      end
    end
    require("fennel").metadata:setall(api["buf-get-lines"], "fnl/arglist", {"bufnr", "start", "end", "strict?"})
    api["buf-set-lines"] = function(bufnr, start, _end, strict_3f, replacement)
      assert((nil ~= replacement), ("Missing argument %s on %s:%s"):format("replacement", "fnl/fennel-nvim/vim-compat.fnl", 32))
      assert((nil ~= strict_3f), ("Missing argument %s on %s:%s"):format("strict?", "fnl/fennel-nvim/vim-compat.fnl", 32))
      assert((nil ~= _end), ("Missing argument %s on %s:%s"):format("end", "fnl/fennel-nvim/vim-compat.fnl", 32))
      assert((nil ~= start), ("Missing argument %s on %s:%s"):format("start", "fnl/fennel-nvim/vim-compat.fnl", 32))
      assert((nil ~= bufnr), ("Missing argument %s on %s:%s"):format("bufnr", "fnl/fennel-nvim/vim-compat.fnl", 32))
      do
        local buf = vim.buffer(bufnr)
        local r_len = #replacement
        local b_len = #buf
        local s = nil
        local function _0_()
          if (0 < start) then
            return (start + b_len + 1)
          else
            return start
          end
        end
        s = (1 + _0_())
        local e = nil
        local function _1_()
          if (0 < _end) then
            return (_end + b_len + 1)
          else
            return _end
          end
        end
        e = (1 + _1_())
        local lines = {}
        if strict_3f then
          assert(((0 <= s) and (b_len >= s) and (0 <= e) and (b_len >= e)), "Index out of bounds")
        else
          s, e = math.min((1 + b_len), math.max(1, s)), math.min((1 + b_len), math.max(1, e))
        end
        for i = 1, ((e - s) - r_len) do
          buf[s] = nil
        end
        for i0 = 0, (r_len - 1) do
          buf[(i0 + s)] = replacement[(i0 + 1)]
        end
        return nil
      end
    end
    require("fennel").metadata:setall(api["buf-set-lines"], "fnl/arglist", {"bufnr", "start", "end", "strict?", "replacement"})
    return api["buf-set-lines"]
  end
end
_0_(...)
return {["is-nvim"] = is_nvim, api = api}
