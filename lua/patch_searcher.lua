local fnl = require("fennel")

function patch_searchers()
  local found = false
  for i, v in ipairs(package.loaders or package.searchers) do
    if v == fnl.searcher then found = true end
  end
  if not found then
    table.insert(package.loaders or package.searchers, fnl.searcher)
  end
end

return patch_searchers
