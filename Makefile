DOC_TEMPLATE=template.html
DOC_TARGET=index.html

all: clean Overview Morsel Meddle WebSockets HttpServer HttpParser HttpCommon versionassets

readmeurl = "https://raw.github.com/hackerschool/$(1).jl/master/docs/$(1).md"

#
# $(1) the GitHub repo name under the hackerschool organization
# $(2) the template directive
#
define curlandcompile
	$(shell if [ ! -f $(DOC_TARGET) ]; then
		cp $(DOC_TEMPLATE) $(DOC_TARGET);
	fi)
	$(eval HTML_TMP := $(shell mktemp 'tmp.html.XXXXX'))
	curl -s $(call readmeurl,$(1)) \
		| python -m markdown -x "codehilite(noclasses=True)" \
		> $(HTML_TMP)
	sed -i '' -e "/$(2)/r $(HTML_TMP)" $(DOC_TARGET)
	rm -f $(HTML_TMP)
endef

#
# $(1) the filepath inside the repo root
# $(2) the template directive
#
define localcompile
	$(shell if [ ! -f $(DOC_TARGET) ]; then
		cp $(DOC_TEMPLATE) $(DOC_TARGET);
	fi)
	$(eval HTML_TMP := $(shell mktemp 'tmp.html.XXXXX'))
	cat $(1) | python -m markdown -x "codehilite(noclasses=True)" > $(HTML_TMP)
	sed -i '' -e "/$(2)/r $(HTML_TMP)" $(DOC_TARGET)
	rm -f $(HTML_TMP)
endef

define version
	sed -i '' -e "s^<!--!!!VERSION:$(shell echo $(1) | tr "/" "\\/")-->^v=$(shell stat -t "%s" -f "%m" $(1))^" $(DOC_TARGET)
endef

Overview:
	$(call localcompile,docs/Overview.md,<!--!!!Overview_content-->)

Morsel:
	$(call curlandcompile,Morsel,<!--!!!Morsel_content-->)

Meddle:
	$(call curlandcompile,Meddle,<!--!!!Meddle_content-->)

WebSockets:
	$(call curlandcompile,WebSockets,<!--!!!WebSockets_content-->)

HttpServer:
	$(call curlandcompile,HttpServer,<!--!!!HttpServer_content-->)

HttpParser:
	$(call curlandcompile,HttpParser,<!--!!!HttpParser_content-->)

HttpCommon:
	$(call curlandcompile,HttpCommon,<!--!!!HttpCommon_content-->)

versionassets:
	$(call version,css/main.css)
	$(call version,js/main.js)

clean:
	rm -f tmp.html.*
	rm -f tmp.md.*
	rm -f $(DOC_TARGET)
