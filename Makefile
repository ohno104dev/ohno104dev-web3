.PHONY: help install dev build preview clean

help:
	@echo "Available targets:"
	@echo "  make install   Install dependencies with npm ci"
	@echo "  make dev       Start the Vite dev server"
	@echo "  make build     Build the production bundle"
	@echo "  make preview   Preview the production build"
	@echo "  make clean     Remove generated build output"

install:
	npm ci

dev:
	npm run dev

build:
	npm run build

preview:
	npm run preview

clean:
	rm -rf dist
