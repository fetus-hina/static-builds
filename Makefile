SUB_DIRS := \
	brotli \
	curl \
	jpegoptim

.PHONY: all clean dist-clean $(SUB_DIRS)
all: $(SUB_DIRS)

clean: $(SUB_DIRS)
	rm -rf bin/*

dist-clean: clean $(SUB_DIRS)

$(SUB_DIRS):
	@$(MAKE) -C $@ $(MAKECMDGOALS)
