NAME  = oxref
STY1  = oxnotes
STY2  = oxyear
SHELL = bash
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t tmp.XXXXXXXXXX)
TDIR  = $(TEMP)/$(NAME)
VERS  = $(shell ltxfileinfo -v $(NAME).tex)
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)
WORKMF = "/home/ab318/Data/TeX/workmf"
all:	$(NAME).pdf $(STY1)-doc.pdf $(STY2)-doc.pdf clean
	exit 0
$(NAME).pdf $(STY1)-doc.tex $(STY2)-doc.tex: $(NAME).tex
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(NAME).tex >/dev/null
$(STY1)-doc.pdf: $(STY1)-doc.tex
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(STY1)-doc.tex >/dev/null
$(STY2)-doc.pdf: $(STY2)-doc.tex
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(STY2)-doc.tex >/dev/null
clean:
	rm -f {$(NAME),$(STY1)-doc,$(STY2)-doc}.{aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,ins,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb}
	rm -f {$(STY1),$(STY2),british-$(NAME)}.doc
distclean: clean
	rm -f $(NAME).bbx $(STY1).bbx $(STY2).bbx british-$(NAME).lbx $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib
inst: $(NAME).pdf clean
	sudo mkdir -p $(UTREE)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(UTREE)/source/latex/$(NAME)
	sudo cp $(STY1).bbx $(STY2).bbx british-$(NAME).lbx $(UTREE)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(UTREE)/doc/latex/$(NAME)
install: $(NAME).pdf clean
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(LOCAL)/source/latex/$(NAME)
	sudo cp $(STY1).bbx $(STY2).bbx british-$(NAME).lbx $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(LOCAL)/doc/latex/$(NAME)
workmf: $(NAME).pdf clean
	sudo mkdir -p $(WORKMF)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(WORKMF)/source/latex/$(NAME)
	sudo cp $(STY1).bbx $(STY2).bbx british-$(NAME).lbx $(WORKMF)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(WORKMF)/doc/latex/$(NAME)
zip: $(NAME).pdf $(STY1)-doc.pdf $(STY2)-doc.pdf clean
	mkdir $(TDIR)
	cp $(NAME).{tex,pdf} $(STY1)-doc.pdf $(STY2)-doc.pdf README.md Makefile $(STY1).bbx $(STY2).bbx british-$(NAME).lbx $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
