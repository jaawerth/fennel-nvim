local fnl = require("fennel")

table.insert(package.loaders or package.searchers, fnl.searcher)
