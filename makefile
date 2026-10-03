IMAGE=zeebo-sdk

docker/shell:
	docker run --platform=linux/amd64 --rm -it -v "$(PWD)":/src -v "$(PWD)/sdk/brew":/opt/brew $(IMAGE)

docker/build:
	docker build --platform=linux/amd64 . -t $(IMAGE)
