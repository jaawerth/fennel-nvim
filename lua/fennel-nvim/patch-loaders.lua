local function mkpatcher()
  local bin = setmetatable({}, {__mode = "k"})
  local function patch(searcher)
    assert((nil ~= searcher), ("Missing argument %s on %s:%s"):format("searcher", "fnl/fennel-nvim/patch-loaders.fnl", 3))
    do
      local loaders = (package.loaders or package.searchers)
      local patched = {}
      for i, s in ipairs(loaders) do
        if patched[s] then
          error("Searchers shouldn't have multiples.")
        elseif (s == searcher) then
          bin[s] = true
          return
        elseif bin[s] then
          patched[s] = i
        end
      end
      do
        local _0_0, _1_0 = next(patched)
        if (true and (nil ~= _1_0)) then
          local _ = _0_0
          local j = _1_0
          loaders[j] = searcher
        else
          local _ = _0_0
          table.insert(loaders, searcher)
        end
      end
      bin[searcher] = true
      return nil
    end
  end
  require("fennel").metadata:setall(patch, "fnl/arglist", {"searcher"})
  local function unpatch(searcher, _3fforce)
    assert((nil ~= searcher), ("Missing argument %s on %s:%s"):format("searcher", "fnl/fennel-nvim/patch-loaders.fnl", 15))
    for i, s in ipairs((package.loaders or package.searchers)) do
      if ((s == searcher) and (bin[s] or _3fforce)) then
        table.remove(package.loaders, i)
      end
    end
    return nil
  end
  require("fennel").metadata:setall(unpatch, "fnl/arglist", {"searcher", "?force"})
  local function clear()
    local loaders = (package.loaders or package.searchers)
    local function recur(i)
      if bin[i] then
        table.remove(loaders, i)
        return recur(i)
      elseif (i < #loaders) then
        return recur((i + 1))
      end
    end
    require("fennel").metadata:setall(recur, "fnl/arglist", {"i"})
    return recur(1)
  end
  require("fennel").metadata:setall(clear, "fnl/arglist", {})
  return {clear = clear, mkpatcher = mkpatcher, patch = patch, patched_weakset = bin, unpatch = unpatch}
end
require("fennel").metadata:setall(mkpatcher, "fnl/arglist", {})
return mkpatcher()
