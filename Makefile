# Makefile to build PDF and Markdown CVs from YAML.

WEBSITE_DIR=${HOME}/Documents/Work/Obsidian/documents/projects/website/colefaraday.github.io
WEBSITE_PDF=$(WEBSITE_DIR)/assets/pdf/cv.pdf
WEBSITE_PAPERS=$(WEBSITE_DIR)/_bibliography/papers.bib
WEBSITE_TALKS=$(WEBSITE_DIR)/_bibliography/talks.bib
WEBSITE_MD=$(WEBSITE_DIR)/_pages/cv.md
WEBSITE_DATE=$(WEBSITE_DIR)/_includes/last-updated.txt

TEMPLATES := $(shell find templates -type f)
BUILD_DIR := build

# Default CV
TEX := $(BUILD_DIR)/cv.tex
PDF := $(BUILD_DIR)/cv.pdf
MD  := $(BUILD_DIR)/cv.md

PAPERS := publications/papers.bib
TALKS  := publications/talks.bib

YAML_FILES := $(wildcard cv*.yaml)

# List of all possible variant names (e.g., 'internal', 'academic')
# This assumes your variant YAMLs are named cv_VARIANT.yaml
VARIANTS := $(patsubst cv_%.yaml,%,$(filter cv_%.yaml,$(YAML_FILES)))

.PHONY: all public stage jekyll push clean fetch-papers viewpdf $(VARIANTS)

all: $(PDF) $(MD)

$(BUILD_DIR):
	mkdir -p $@

# Default rule: use cv.yaml [+ optional cv.hidden.yaml]
$(TEX) $(MD): generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(BUILD_DIR)
	./generate.py cv.yaml $(if $(wildcard cv.hidden.yaml),cv.hidden.yaml) --outdir=$(BUILD_DIR)

$(PDF): $(TEX)
	latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=$(BUILD_DIR)/cv $(BUILD_DIR)/cv
	latexmk -c -cd $(BUILD_DIR)/cv

## Variant Rules

# Phony targets for each variant (e.g., 'make internal')
$(VARIANTS):
	$(MAKE) $(BUILD_DIR)/$@/cv.pdf $(BUILD_DIR)/$@/cv.md

# This is a pattern rule for generating the .tex and .md for any variant
# Target: build/variant_name/cv.tex and build/variant_name/cv.md
$(BUILD_DIR)/%/cv.tex $(BUILD_DIR)/%/cv.md: generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$*
	./generate.py cv.yaml cv_$*.yaml --outdir=$(BUILD_DIR)/$*

# This is a pattern rule for building the PDF for any variant
# Target: build/variant_name/cv.pdf
$(BUILD_DIR)/%/cv.pdf: $(BUILD_DIR)/%/cv.tex
	latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=cv -outdir=$(BUILD_DIR)/$* $(BUILD_DIR)/$*/cv
	# Clean up also uses -outdir to point to the correct temporary files
	latexmk -c -cd $(BUILD_DIR)/$*/cv

## Other Rules

public: all

viewpdf: $(PDF)
	xdg-open $(PDF)

stage: $(PDF) $(MD)
	git -C $(WEBSITE_DIR) checkout $(WEBSITE_PDF) $(WEBSITE_MD) $(WEBSITE_PAPERS) $(WEBSITE_TALKS)
	git -C $(WEBSITE_DIR) pull --rebase
	cp $(PDF) $(WEBSITE_PDF)
	cp $(MD) $(WEBSITE_MD)
	cp $(PAPERS) $(WEBSITE_PAPERS)
	cp $(TALKS) $(WEBSITE_TALKS)

jekyll: stage
	cd $(WEBSITE_DIR) && bundle exec jekyll serve

push: stage
	git -C $(WEBSITE_DIR) add $(WEBSITE_PDF) $(WEBSITE_MD)
	git -C $(WEBSITE_DIR) commit -m "Update CV."
	git -C $(WEBSITE_DIR) push

fetch-papers:
	cd publications && fetch_inspire_bib_from_search "a Faraday, c" papers
	@echo "Papers fetched."

clean:
	rm -rf `biber --cache`
	rm -rf $(BUILD_DIR)