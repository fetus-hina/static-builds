BINARIES := \
	brotli \
	curl \
	jpegoptim \
	openssl \
	zopfli \
	zopflipng

BINARY_PATHS := $(addprefix ./bin/, $(BINARIES))
TAR_PATH := ./bin/bin.tar.gz
IMAGE_NAME := static_builder_$(shell date '+%s')

.PHONY: all clean build

all: $(BINARY_PATHS)

$(BINARY_PATHS): $(TAR_PATH)
	tar -zxf $(TAR_PATH) bin/$(notdir $@) -O > $@

$(TAR_PATH): build
	mkdir -p $(dir $@)
	docker run --name $(IMAGE_NAME)-exec $(IMAGE_NAME)
	docker wait $(IMAGE_NAME)-exec
	docker cp $(IMAGE_NAME)-exec:/opt/$(notdir $@) $@
	docker rm $(IMAGE_NAME)-exec

build:
	docker kill $(IMAGE_NAME) || true 2>&1 >/dev/null
	docker rm $(IMAGE_NAME) || true 2>&1 >/dev/null
	docker build -t $(IMAGE_NAME) .

dist-clean: clean

clean:
	docker rm $(IMAGE_NAME) || true
	docker images | grep -q $(IMAGE_NAME) && docker rmi $(IMAGE_NAME) || true
