GIT_VER := $(shell git describe --tags --always --dirty="-dev")

all: clean build

v:
	@echo "Version: ${GIT_VER}"

clean:
	git clean -fdx

build:
	go build -ldflags "-X cmd.Version=${GIT_VER} -X main.Version=${GIT_VER}" -v -o boost-relay .

test:
	go test ./...

test-race:
	go test -race ./...

lint:
	gofmt -d -s .
	gofumpt -d -extra .
	go vet ./...
	staticcheck ./...
	golangci-lint run

gofumpt:
	gofumpt -l -w -extra .

test-coverage:
	go test -race -v -covermode=atomic -coverprofile=coverage.out ./...
	go tool cover -func coverage.out

cover-html:
	go test -coverprofile=/tmp/boost-relay.cover.tmp ./...
	go tool cover -html=/tmp/boost-relay.cover.tmp
	unlink /tmp/boost-relay.cover.tmp

docker-image:
	DOCKER_BUILDKIT=1 docker build --build-arg GIT_VER=${GIT_VER} . -t mev-boost-relay

docker-image-amd:
	DOCKER_BUILDKIT=1 docker build --platform linux/amd64 --build-arg GIT_VER=${GIT_VER} . -t mev-boost-relay
