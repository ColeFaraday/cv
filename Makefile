# Makefile to build PDF and Markdown cv from YAML.
#
# Brandon Amos <http://bamos.github.io> and
# Ellis Michael <http://ellismichael.com>

WEBSITE_DIR=${HOME}/Documents/Work/Obsidian/documents/projects/website/colefaraday.github.io
WEBSITE_PDF=$(WEBSITE_DIR)/assets/pdf/cv.pdf
WEBSITE_PAPERS=$(WEBSITE_DIR)/_bibliography/papers.bib
WEBSITE_TALKS=$(WEBSITE_DIR)/_bibliography/talks.bib
WEBSITE_MD=$(WEBSITE_DIR)/_pages/cv.md
WEBSITE_DATE=$(WEBSITE_DIR)/_includes/last-updated.txt

TEMPLATES=$(shell find templates -type f)

BUILD_DIR=build
TEX=$(BUILD_DIR)/cv.tex
PDF=$(BUILD_DIR)/cv.pdf
PAPERS=publications/papers.bib
TALKS=publications/talks.bib
MD=$(BUILD_DIR)/cv.md

ifneq ("$(wildcard cv.hidden.yaml)","")
	YAML_FILES = cv.yaml cv.hidden.yaml
else
	YAML_FILES = cv.yaml
endif

.PHONY: all public viewpdf stage jekyll push clean fetch-papers

all: 
	$(PDF) $(MD)
	eval "$(pyenv init --path)"
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

public: $(BUILD_DIR) $(TEMPLATES) $(YAML_FILES) generate.py
	./generate.py cv.yaml

$(TEX) $(MD): $(TEMPLATES) $(YAML_FILES) generate.py publications/*.bib
	./generate.py $(YAML_FILES)

$(PDF): $(TEX)
	# TODO: Hack for biber on OSX.
	rm -rf /var/folders/8p/lzk2wkqj47g5wf8g8lfpsk4w0000gn/T/par-62616d6f73

	latexmk -pdflatex=lualatex -pdf -cd- -jobname=$(BUILD_DIR)/cv $(BUILD_DIR)/cv
	latexmk -c -cd $(BUILD_DIR)/cv

viewpdf: $(PDF)
	gnome-open $(PDF)

stage: $(PDF) $(MD)
	git -C $(WEBSITE_DIR) checkout $(WEBSITE_PDF) $(WEBSITE_MD) $(WEBSITE_PAPERS) $(WEBSITE_TALKS) # $(WEBSITE_DATE)
	git -C $(WEBSITE_DIR) pull --rebase
	cp $(PDF) $(WEBSITE_PDF)
	cp $(MD) $(WEBSITE_MD)
	cp $(PAPERS) $(WEBSITE_PAPERS)
	cp $(TALKS) $(WEBSITE_TALKS)
	# date +%Y-%m-%d > $(WEBSITE_DATE). I don't need this.

jekyll: stage
	cd $(WEBSITE_DIR) && bundle exec jekyll server

push: stage
	git -C $(WEBSITE_DIR) add $(WEBSITE_PDF) $(WEBSITE_MD) $(WEBSITE_DATE)
	git -C $(WEBSITE_DIR) commit -m "Update cv."
	git -C $(WEBSITE_DIR) push

fetch-papers:
	@echo "Fetching papers for 'a Faraday, c' from InspireHEP..."
	cd publications
	fetch_inspire_bib_from_search "a Faraday, c" publications/papers
	cd ..
	@echo "Papers fetched successfully!"

clean:
	rm -rf *.db $(BUILD_DIR)/cv*
