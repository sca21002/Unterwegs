FONTAWESOME_WEBFONT = $(addprefix fonts/fontawesome-webfont., eot ttf woff woff2)

UNTERWEGS_APPS_LESS_FILES := $(shell find less -type f -name '*.less')

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Main targets:"
	@echo
	@echo "- help                    Display this help message"
	@echo "- build-veduta-app        Build a compiled version of the app in one file"
	@echo "- clean                   Remove generated files"
	@echo "- cleanall                Remove all the build artefacts"
	@echo "- serve                   Run a development web server for running the examples"
	@echo

.PHONY: serve
serve: .build/node_modules.timestamp $(FONTAWESOME_WEBFONT)
	node buildtools/serve.js

.build/node_modules.timestamp: package.json
	npm install
	mkdir -p $(dir $@)
	touch $@

.PRECIOUS: node_modules/font-awesome/fonts/fontawesome-webfont.%
node_modules/font-awesome/fonts/fontawesome-webfont.%: .build/node_modules.timestamp
	touch -c $@

fonts/fontawesome-webfont.%: node_modules/font-awesome/fonts/fontawesome-webfont.%
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: compile-css
compile-css: build/unterwegs.css

build/%.css: less/unterwegs.less \
		$(UNTERWEGS_APPS_LESS_FILES) \
		.build/node_modules.timestamp \
		$(FONTAWESOME_WEBFONT)
	mkdir -p $(dir $@)
	./node_modules/.bin/lessc --autoprefix --clean-css="--s0" $< $@

