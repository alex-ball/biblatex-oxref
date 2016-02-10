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
	@exit 0
$(STY1)-doc.tex $(STY2)-doc.tex $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx: $(NAME).tex
	lualatex -interaction=batchmode $(NAME).tex >/dev/null
$(NAME).pdf: $(NAME).tex $(NAME).bbx $(STY1).bbx $(STY1).cbx british-$(NAME).lbx
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(NAME).tex >/dev/null
$(STY1)-doc.pdf: $(STY1)-doc.tex $(NAME).bbx $(STY1).bbx $(STY1).cbx british-$(NAME).lbx
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(STY1)-doc.tex >/dev/null
$(STY2)-doc.pdf: $(STY2)-doc.tex $(NAME).bbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx
	latexmk -lualatex -synctex=1 -interaction=batchmode -silent $(STY2)-doc.tex >/dev/null
clean:
	rm -f {$(NAME),$(STY1)-doc,$(STY2)-doc}.{aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,ins,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb}
	rm -f {$(STY1),$(STY2),british-$(NAME)}.doc
distclean: clean
	rm -f $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib
inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/latex/$(NAME)
	cp $(NAME).tex $(UTREE)/source/latex/$(NAME)
	cp $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(UTREE)/tex/latex/$(NAME)
	cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(UTREE)/doc/latex/$(NAME)
install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).tex $(LOCAL)/source/latex/$(NAME)
	sudo cp $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(LOCAL)/doc/latex/$(NAME)
workmf: all
	mkdir -p $(WORKMF)/{tex,source,doc}/latex/$(NAME)
	cp $(NAME).tex $(WORKMF)/source/latex/$(NAME)
	cp $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(WORKMF)/tex/latex/$(NAME)
	cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(WORKMF)/doc/latex/$(NAME)
zip: $(NAME).pdf $(STY1)-doc.pdf $(STY2)-doc.pdf clean
	mkdir $(TDIR)
	cp $(NAME).{tex,pdf} $(STY1)-doc.pdf $(STY2)-doc.pdf README.md Makefile $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
