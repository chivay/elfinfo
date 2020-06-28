.PHONY: build clean
build:
	zig build-exe --release-fast elfinfo.zig
fmt:
	zig fmt elfinfo.zig defs.zig

clean:
	rm -rf *.o elfinfo
