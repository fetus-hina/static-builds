BINARY := ../bin/zopfli
IMAGE_NAME := zopfli_builder

.PHONY: all clean build

all: $(BINARY)

$(BINARY): build
	docker run --name $(IMAGE_NAME)-exec $(IMAGE_NAME)
	docker wait $(IMAGE_NAME)-exec
	docker cp $(IMAGE_NAME)-exec:/opt/zopfli/bin/zopfli ../bin/zopfli
	docker cp $(IMAGE_NAME)-exec:/opt/zopfli/bin/zopflipng ../bin/zopflipng
	docker rm $(IMAGE_NAME)-exec

build:
	docker kill $(IMAGE_NAME) || true 2>&1 >/dev/null
	docker rm $(IMAGE_NAME) || true 2>&1 >/dev/null
	docker build -t $(IMAGE_NAME) .

dist-clean: clean

clean:
	docker rm $(IMAGE_NAME) || true
	docker images | grep -q $(IMAGE_NAME) && docker rmi $(IMAGE_NAME) || true
