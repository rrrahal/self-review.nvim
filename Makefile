.PHONY: test

test:
	nvim --headless -u tests/prepare_env.lua -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/prepare_env.lua' }"
