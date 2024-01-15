# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
BIB := $(CWD)/bib
OUT := $(CWD)/out

# TODO@dpwiese - do xelatex and lualatex work?
ENGINE := pdflatex

# Source files
SRC_FILES := $(wildcard $(SRC)/*.tex) $(wildcard $(SRC)/*/*.tex)

.PHONY: pdf clean lint
.SILENT: pdf clean lint

pdf: $(subst src,out,$(subst .tex,.pdf, $(wildcard $(SRC)/*.tex)))

clean:
	- rm -f $(OUT)/*

$(OUT):
	mkdir -p $@

$(OUT)/%.pdf: $(SRC_FILES) $(BIB)/%.bib | $(OUT)
	cd $(SRC) \
	&& openout_any=a $(ENGINE) --jobname=$(notdir $(basename $@)) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& cd $(OUT) && openout_any=a bibtex $(notdir $(basename $@)) && cd $(SRC) \
	&& openout_any=a $(ENGINE) --jobname=$(notdir $(basename $@)) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& openout_any=a $(ENGINE) --jobname=$(notdir $(basename $@)) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& cd ..

lint:
	chktex -I0 -l $(SRC)/.chktexrc $(SRC_FILES)
	$(foreach x, $(SRC_FILES), lacheck $(x);)
