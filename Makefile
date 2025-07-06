# Makefile to build PDF and Markdown CVs from YAML.

# Use bash as the shell and evaluate pyenv commands first
SHELL := /bin/sh
.SHELLFLAGS := c

# Set up pyenv for every recipe
PYENV_SETUP = \
	eval "$$(pyenv init --path)"; \
	eval "$$(pyenv init -)"; \
	eval "$$(pyenv virtualenv-init -)";

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
	$(PYENV_SETUP) mkdir -p $@

# Default rule: use cv.yaml [+ optional cv.hidden.yaml]
$(TEX) $(MD): generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(BUILD_DIR)
	$(PYENV_SETUP) ./generate.py cv.yaml $(if $(wildcard cv.hidden.yaml),cv.hidden.yaml) --outdir=$(BUILD_DIR)

$(PDF): $(TEX)
	$(PYENV_SETUP) latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=$(BUILD_DIR)/cv $(BUILD_DIR)/cv
	$(PYENV_SETUP) latexmk -c -cd $(BUILD_DIR)/cv

## Variant Rules

# Phony targets for each variant (e.g., 'make internal')
$(VARIANTS):
	$(MAKE) $(BUILD_DIR)/$@/cv.pdf $(BUILD_DIR)/$@/cv.md

# Pattern rule for generating .tex and .md for any variant
$(BUILD_DIR)/%/cv.tex $(BUILD_DIR)/%/cv.md: generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(BUILD_DIR)
	$(PYENV_SETUP) mkdir -p $(BUILD_DIR)/$*
	$(PYENV_SETUP) ./generate.py cv.yaml cv_$*.yaml --outdir=$(BUILD_DIR)/$*

# Pattern rule for building PDF for any variant
$(BUILD_DIR)/%/cv.pdf: $(BUILD_DIR)/%/cv.tex
	$(PYENV_SETUP) latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=cv -outdir=$(BUILD_DIR)/$* $(BUILD_DIR)/$*/cv
	$(PYENV_SETUP) latexmk -c -cd $(BUILD_DIR)/$*/cv

## Other Rules

public: all

viewpdf: $(PDF)
	$(PYENV_SETUP) xdg-open $(PDF)

stage: $(PDF) $(MD)
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) checkout $(WEBSITE_PDF) $(WEBSITE_MD) $(WEBSITE_PAPERS) $(WEBSITE_TALKS)
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) pull --rebase
	$(PYENV_SETUP) cp $(PDF) $(WEBSITE_PDF)
	$(PYENV_SETUP) cp $(MD) $(WEBSITE_MD)
	$(PYENV_SETUP) cp $(PAPERS) $(WEBSITE_PAPERS)
	$(PYENV_SETUP) cp $(TALKS) $(WEBSITE_TALKS)

jekyll: stage
	$(PYENV_SETUP) cd $(WEBSITE_DIR) && bundle exec jekyll serve

push: stage
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) add $(WEBSITE_PDF) $(WEBSITE_MD)
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) commit -m "Update CV."
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) push

fetch-papers:
	$(PYENV_SETUP) cd publications && fetch_inspire_bib_from_search "a Faraday, c" papers
	@echo "Papers fetched."

clean:
	$(PYENV_SETUP) rm -rf `biber --cache`
	$(PYENV_SETUP) rm -rf $(BUILD_DIR)