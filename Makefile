.PHONY: help install build clean start connect

USER_ID = $(shell id -u)
GROUP_ID = $(shell id -g)

export UID = $(USER_ID)
export GID = $(GROUP_ID)

BIN = docker run -i -t --rm \
	--user "${UID}:${GID}" \
	-v "${PWD}:/app" \
	ocamlinvader

all: build

help: ## Display available commands
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	docker build --tag=ocamlinvader .

build: ## Build project
	$(BIN) bash -c "obuild configure && obuild build"

clean: ## Clean project
	$(BIN) bash -c "obuild clean"

start: ## Start project
	$(MAKE) build
	./ocaml-invader || $(MAKE) start-advice
	$(MAKE) clean

connect: ## Connect to container
	$(BIN) bash

deps-install: ## Install required system deps
	opam install depext
	opam depext lablgl

start-advice: ## Display an advice on start error
	@echo "\n  ============================= ERROR ================================"
	@echo "     Please ensure that glut ("freeglut3" on debian) is installed"
	@echo "   You can install required dependencies using 'make deps-install' "
	@echo "  ====================================================================\n"
