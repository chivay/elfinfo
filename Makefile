.PHONY: build clean
build:
	zig build-exe --release-fast elfinfo.zig

clean:
	rm -rf *.o elfinfo
