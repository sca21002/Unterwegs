SRC_JS_FILES := $(shell find src -type f -name '*.js')
NGEO_DIRECTIVES_PARTIALS_FILES := $(shell ls -1 node_modules/ngeo/src/directives/partials/*.html)
UNTERWEGS_DIRECTIVES_PARTIALS_FILES := $(shell ls -1 src/directives/partials/*.html)

NGEO_SRC_JS_FILES := $(shell find node_modules/ngeo/src/ -type f -name '*.js')

FONTAWESOME_WEBFONT = $(addprefix fonts/fontawesome-webfont., eot ttf woff woff2)

UNTERWEGS_APPS_LIBS_JS_FILES += \
	node_modules/jquery/dist/jquery.min.js \
	node_modules/angular/angular.min.js \
	node_modules/angular-float-thead/angular-floatThead.js \
	node_modules/angular-gettext/dist/angular-gettext.min.js \
	node_modules/angular-ui-date/dist/date.js \
	node_modules/bootstrap/dist/js/bootstrap.min.js \
	node_modules/ui-bootstrap-custom/ui-bootstrap-custom-tpls-2.5.0.min.js \
	node_modules/d3/build/d3.min.js \
	node_modules/file-saver/FileSaver.min.js

UNTERWEGS_APPS_LESS_FILES := $(shell find less -type f -name '*.less')

EXTERNS_ANGULAR = .build/externs/angular-1.5.js
EXTERNS_ANGULAR_Q = .build/externs/angular-1.5-q_templated.js
EXTERNS_ANGULAR_HTTP_PROMISE = .build/externs/angular-1.5-http-promise_templated.js
EXTERNS_JQUERY = .build/externs/jquery-1.9.js
EXTERNS_FILES = $(EXTERNS_ANGULAR) $(EXTERNS_ANGULAR_Q) $(EXTERNS_ANGULAR_HTTP_PROMISE) $(EXTERNS_JQUERY)

STAT_COMPRESSED = stat -c '  compressed: %s bytes'
STAT_UNCOMPRESSED = stat -c 'uncompressed: %s bytes'
STAT_LAST_MODIFIED = stat -c '%y'
TOUCH_DATE = touch --date
SED_NEW_LINE = ''

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Main targets:"
	@echo
	@echo "- help                    Display this help message"
	@echo "- build-unterwegs-app     Build a compiled version of the app in one file"
	@echo "- clean                   Remove generated files"
	@echo "- cleanall                Remove all the build artefacts"
	@echo "- serve                   Run a development web server for running the examples"
	@echo

.PHONY: build-veduta-app
build-unterwegs-app: build/unterwegs.js

.PHONY: serve
serve: .build/node_modules.timestamp $(FONTAWESOME_WEBFONT)
	node buildtools/serve.js

.build/node_modules.timestamp: package.json
	npm install
	mkdir -p $(dir $@)
	touch $@

.PRECIOUS: .build/.js
.build/unterwegs.js: .build/app-unterwegs.json \
		$(EXTERNS_FILES) \
		$(NGEO_SRC_JS_FILES) \
		$(SRC_JS_FILES) \
		.build/unterwegstemplatecache.js \
		.build/node_modules.timestamp
	mkdir -p $(dir $@)
	/usr/bin/node buildtools/build.js $< $@
	echo '//# sourceMappingURL=unterwegs.js.map' >> $@
	@$(STAT_UNCOMPRESSED) $@
	@cp $@ /tmp/
	@gzip /tmp/unterwegs.js
	@$(STAT_COMPRESSED) /tmp/unterwegs.js.gz
	@rm /tmp/unterwegs.js.gz

.PRECIOUS: .build/app-unterwegs.json
.build/app-unterwegs.json: buildtools/mako_build.json .build/python-venv/bin/mako-render
	mkdir -p $(dir $@)
	PYTHONIOENCODING=UTF-8 .build/python-venv/bin/mako-render \
		--var 'src=app/**/*.js' \
		--var src_set=contribs_unterwegs \
		--var ngeo_folder=node_modules/ngeo/ \
		--var entry_point=app_unterwegs \
		--var source_map=build/unterwegs.js.map $< > $@

.PRECIOUS: node_modules/font-awesome/fonts/fontawesome-webfont.%
node_modules/font-awesome/fonts/fontawesome-webfont.%: .build/node_modules.timestamp
	touch -c $@

fonts/fontawesome-webfont.%: node_modules/font-awesome/fonts/fontawesome-webfont.%
	mkdir -p $(dir $@)
	cp $< $@

build/unterwegs.js: .build/unterwegs.js $(UNTERWEGS_APPS_LIBS_JS_FILES)
	mkdir -p $(dir $@)
	awk 'FNR==1{print ""}1' $(UNTERWEGS_APPS_LIBS_JS_FILES) $< > $@

build/unterwegs-debug.js: buildtools/unterwegs-debug.json \
		$(EXTERNS_FILES) \
		$(NGEO_SRC_JS_FILES) \
		$(SRC_JS_FILES) \
		.build/unterwegstemplatecache.js \
		.build/node_modules.timestamp
	mkdir -p $(dir $@)
	node buildtools/build.js $< $@

.PHONY: compile-css
compile-css: build/unterwegs.css

build/%.css: less/unterwegs.less \
		$(UNTERWEGS_APPS_LESS_FILES) \
		.build/node_modules.timestamp \
		$(FONTAWESOME_WEBFONT)
	mkdir -p $(dir $@)
	./node_modules/.bin/lessc --autoprefix --clean-css="--s0" $< $@

.build/python-venv:
	mkdir -p $(dir $@)
	virtualenv --no-site-packages $@

$(EXTERNS_ANGULAR):
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.5.js
	touch $@

$(EXTERNS_ANGULAR_Q):
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.5-q_templated.js
	touch $@

$(EXTERNS_ANGULAR_HTTP_PROMISE):
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.5-http-promise_templated.js
	touch $@

$(EXTERNS_JQUERY):
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/jquery-1.9.js
	touch $@

.build/python-venv/bin/mako-render: .build/python-venv
	.build/python-venv/bin/pip install "Mako==1.0.0" "htmlmin==0.1.10"
	touch $@

.build/unterwegstemplatecache.js: buildtools/templatecache.mako.js \
		.build/python-venv/bin/mako-render \
		$(NGEO_DIRECTIVES_PARTIALS_FILES) $(UNTERWEGS_DIRECTIVES_PARTIALS_FILES)
	PYTHONIOENCODING=UTF-8 .build/python-venv/bin/mako-render \
		--var "partials=ngeo:node_modules/ngeo/src/directives/partials unterwegs:src/directives/partials" \
		--var "app=unterwegs" $< > $@

