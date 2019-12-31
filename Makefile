FNL := ./build/fennel
FNL_FLAGS := --compile --metadata
LUA = $(addprefix ./lua/fennel-nvim/,init.lua client.lua complete.lua patch-loaders.lua\
	  update-fennel-paths.lua utils.lua vim-compat.lua lib/fennelview.lua)

.PHONY: clean


build: $(LUA)

clean:
	rm -f $(LUA)

lua/fennel-nvim/%.lua: fnl/fennel-nvim/%.fnl
	$(FNL) $(FNL_FLAGS) $< > $@


.DEFAULT_TARGET: build
