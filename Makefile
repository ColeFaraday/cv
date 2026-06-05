# Makefile to build PDF and Markdown CVs from YAML.

# Use bash as the shell and evaluate pyenv commands first
SHELL := /bin/sh
.SHELLFLAGS := c

# Set up pyenv for every recipe
PYENV_SETUP = \
	eval "$$(pyenv init --path)"; \
	eval "$$(pyenv init -)"; \
	eval "$$(pyenv virtualenv-init -)";

WEBSITE_DIR=${HOME}/Documents/Work/documents/projects/website/colefaraday.github.io
WEBSITE_PDF=$(WEBSITE_DIR)/assets/pdf/cv.pdf
WEBSITE_PAPERS=$(WEBSITE_DIR)/_bibliography/papers.bib
WEBSITE_TALKS=$(WEBSITE_DIR)/_bibliography/talks.bib
WEBSITE_MD=$(WEBSITE_DIR)/_pages/cv.md
WEBSITE_DATE=$(WEBSITE_DIR)/_includes/last-updated.txt
WEBSITE_SLIDES=$(WEBSITE_DIR)/assets/slides

# Local slides source of truth (drop new talk PDFs/PPTX here)
SLIDES_DIR := assets/slides

# Commit message for `make push` (override: make push MSG="...")
MSG ?= Update CV/pubs

TEMPLATES := $(shell find templates -type f)
BUILD_DIR := build

# Default CV
TEX := $(BUILD_DIR)/cv.tex
PDF := $(BUILD_DIR)/cv.pdf
MD  := $(BUILD_DIR)/cv.md

# One-page CV
ONE_PAGE_BUILD_DIR := build_one_page
ONE_PAGE_TEX := $(ONE_PAGE_BUILD_DIR)/cv.tex
ONE_PAGE_PDF := $(ONE_PAGE_BUILD_DIR)/cv.pdf

PAPERS := publications/papers.bib
TALKS  := publications/talks.bib

YAML_FILES := $(wildcard cv*.yaml)

# List of all possible variant names (e.g., 'internal', 'academic')
# This assumes your variant YAMLs are named cv_VARIANT.yaml
# Exclude one_page since it has its own dedicated rules
VARIANTS := $(filter-out one_page,$(patsubst cv_%.yaml,%,$(filter cv_%.yaml,$(YAML_FILES))))

.PHONY: all public stage jekyll push clean fetch-papers viewpdf one_page $(VARIANTS)

all: $(PDF) $(MD) one_page

$(BUILD_DIR):
	$(PYENV_SETUP) mkdir -p $@

# Default rule: use cv.yaml [+ optional cv.hidden.yaml]
$(TEX) $(MD): generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(BUILD_DIR)
	$(PYENV_SETUP) ./generate.py cv.yaml $(if $(wildcard cv.hidden.yaml),cv.hidden.yaml) --outdir=$(BUILD_DIR)

$(PDF): $(TEX)
	$(PYENV_SETUP) latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=$(BUILD_DIR)/cv $(BUILD_DIR)/cv
	$(PYENV_SETUP) latexmk -c -cd $(BUILD_DIR)/cv

## One-page CV Rules

.PHONY: one_page
one_page: $(ONE_PAGE_PDF)

$(ONE_PAGE_BUILD_DIR):
	$(PYENV_SETUP) mkdir -p $@

$(ONE_PAGE_TEX): generate.py $(TEMPLATES) $(YAML_FILES) $(PAPERS) $(TALKS) | $(ONE_PAGE_BUILD_DIR)
	$(PYENV_SETUP) ./generate.py cv.yaml cv_one_page.yaml --outdir=$(ONE_PAGE_BUILD_DIR)

$(ONE_PAGE_PDF): $(ONE_PAGE_TEX)
	$(PYENV_SETUP) latexmk -gg -pdflatex=lualatex -pdf -cd- -jobname=$(ONE_PAGE_BUILD_DIR)/cv $(ONE_PAGE_BUILD_DIR)/cv
	$(PYENV_SETUP) latexmk -c -cd $(ONE_PAGE_BUILD_DIR)/cv

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
	## $(PYENV_SETUP) git -C $(WEBSITE_DIR) checkout $(WEBSITE_PDF) $(WEBSITE_MD) $(WEBSITE_PAPERS) $(WEBSITE_TALKS)
	## $(PYENV_SETUP) git -C $(WEBSITE_DIR) pull --rebase
	$(PYENV_SETUP) cp $(PDF) $(WEBSITE_PDF)
	$(PYENV_SETUP) cp $(MD) $(WEBSITE_MD)
	$(PYENV_SETUP) cp $(PAPERS) $(WEBSITE_PAPERS)
	$(PYENV_SETUP) cp $(TALKS) $(WEBSITE_TALKS)
	$(PYENV_SETUP) mkdir -p $(WEBSITE_SLIDES)
	$(PYENV_SETUP) rsync -a $(SLIDES_DIR)/ $(WEBSITE_SLIDES)/

jekyll: stage
	$(PYENV_SETUP) cd $(WEBSITE_DIR) && bundle exec jekyll serve

push: stage
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) add -A
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) commit -m "$(MSG)" || echo "website: nothing to commit"
	$(PYENV_SETUP) git -C $(WEBSITE_DIR) push
	$(PYENV_SETUP) git add -A
	$(PYENV_SETUP) git commit -m "$(MSG)" || echo "cv: nothing to commit"
	$(PYENV_SETUP) git push

fetch-papers:
	$(PYENV_SETUP) cd publications && fetch_inspire_bib_from_search "a Faraday, c" papers
	@echo "Papers fetched."

clean:
	$(PYENV_SETUP) rm -rf `biber --cache`
	$(PYENV_SETUP) rm -rf $(BUILD_DIR)
	$(PYENV_SETUP) rm -rf $(ONE_PAGE_BUILD_DIR)