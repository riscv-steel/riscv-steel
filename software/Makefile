MAKEFLAGS += --no-print-directory

all: debug

debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX:+-DTOOLCHAIN_PREFIX= "${TOOLCHAIN_PREFIX}"}..
	@make -C build

release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX:+-DTOOLCHAIN_PREFIX= "${TOOLCHAIN_PREFIX}"} ..
	@make -C build

clean:
	@rm -rf build
	@echo "Build directory deleted."

.PHONY: clean debug release
