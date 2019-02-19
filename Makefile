NAME  = oxref
PFX   = biblatex-
STY1  = oxnotes
STYS  = oxnotes oxyear oxnum oxalph
VARS  = ibid note inote trad1 trad2 trad3
AUX   = aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb
SHELL = bash
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t tmp.XXXXXXXXXX)
TDIR  = $(TEMP)/$(NAME)
VERS  = $(shell ltxfileinfo -v $(NAME).dtx)
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)

.PHONY: source clean distclean inst uninst install uninstall zip ctan

all: $(NAME).pdf $(STYS:%=%-doc.pdf) clean
	@exit 0

source $(NAME).bbx american-$(NAME).lbx british-$(NAME).lbx english-$(NAME).lbx $(STYS:%=%-doc.tex) $(STYS:%=%.bbx) $(STYS:%=%.cbx) $(STYS:%=%.dbx) $(VARS:%=$(STY1)-%.bbx) $(VARS:%=$(STY1)-%.cbx) $(VARS:%=$(STY1)-%.dbx): $(NAME).dtx
	luatex -interaction=nonstopmode $(NAME).dtx >/dev/null

$(NAME).pdf: $(NAME).dtx $(NAME).bbx $(STY1).bbx $(STY1).cbx british-$(NAME).lbx english-$(NAME).lbx
	latexmk -silent -lualatex -shell-escape -interaction=nonstopmode $(NAME).dtx >/dev/null
$(STYS:%=%-doc.pdf): %-doc.pdf : %-doc.tex $(NAME).bbx %.bbx %.cbx british-$(NAME).lbx english-$(NAME).lbx
	latexmk -silent -lualatex -shell-escape -interaction=nonstopmode $< >/dev/null

clean:
	for log in *.log; do [ -e "$$log" ] || continue; grep "WARNING: biblatex-oxref" $$log; test $$? -eq 1; done
	rm -f $(NAME).{$(AUX)} $(STYS:%=%-doc.{$(AUX)})
	rm -f $(STYS:%=%.doc) {american,british,english}-$(NAME).doc
	rm -rf _minted-*
	rm -f $(NAME).markdown.in
	rm -rf _markdown_*
distclean: clean
	rm -f $(NAME).{bbx,bib,ins,pdf} $(STYS:%=%.{b,c,d}bx) $(VARS:%=$(STY1)-%.{b,c,d}bx) {american,british,english}-$(NAME).lbx $(STYS:%=%-doc.{tex,pdf})

inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/latex/$(PFX)$(NAME)
	cp $(NAME).{dtx,ins} $(UTREE)/source/latex/$(PFX)$(NAME)
	cp $(NAME).bbx $(STYS:%=%.{b,c,d}bx) $(VARS:%=$(STY1)-%.{b,c,d}bx) {american,british,english}-$(NAME).lbx $(UTREE)/tex/latex/$(PFX)$(NAME)
	cp $(NAME).{bib,pdf} $(STYS:%=%-doc.{tex,pdf}) $(UTREE)/doc/latex/$(PFX)$(NAME)
	mktexlsr
uninst:
	rm -r $(UTREE)/{tex,source,doc}/latex/$(PFX)$(NAME)
	mktexlsr

install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(PFX)$(NAME)
	sudo cp $(NAME).{dtx,ins} $(LOCAL)/source/latex/$(PFX)$(NAME)
	sudo cp $(NAME).bbx $(STYS:%=%.{b,c,d}bx) $(VARS:%=$(STY1)-%.{b,c,d}bx) {american,british,english}-$(NAME).lbx $(LOCAL)/tex/latex/$(PFX)$(NAME)
	sudo cp $(NAME).{bib,pdf} $(STYS:%=%-doc.{tex,pdf}) $(LOCAL)/doc/latex/$(PFX)$(NAME)
	sudo mktexlsr
uninstall:
	sudo rm -r $(LOCAL)/{tex,source,doc}/latex/$(PFX)$(NAME)
	sudo mktexlsr

zip: all
	mkdir $(TDIR)
	cp $(NAME).{dtx,pdf} $(STYS:%=%-doc.pdf) README.md Makefile $(NAME).bbx $(STYS:%=%.{b,c,d}bx) $(VARS:%=$(STY1)-%.{b,c,d}bx) {american,british,english}-$(NAME).lbx $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(PFX)$(NAME)-$(VERS).zip $(NAME)
ctan: all
	mkdir $(TDIR)
	cp $(NAME).{dtx,pdf} $(STYS:%=%-doc.pdf) README.md Makefile $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(PFX)$(NAME)-$(VERS).zip $(NAME)
