NAME  = oxref
SHELL = bash
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t tmp.XXXXXXXXXX)
TDIR  = $(TEMP)/$(NAME)
VERS  = $(shell ltxfileinfo -v $(NAME).tex)
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)
WORKMF = "/home/ab318/Data/TeX/workmf"
all:	$(NAME).pdf $(NAME)-notes-doc.pdf clean
	exit 0
$(NAME).pdf $(NAME)-notes-doc.tex: $(NAME).tex
	latexmk -pdf -silent -pdflatex="lualatex -synctex=1 -interaction=batchmode %O %S" $(NAME).tex >/dev/null
$(NAME)-notes-doc.pdf: $(NAME)-notes-doc.tex
	latexmk -pdf -silent -pdflatex="lualatex -synctex=1 -interaction=batchmode %O %S" $(NAME)-notes-doc.tex >/dev/null
clean:
	rm -f $(NAME).{aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,ins,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb}
	rm -f $(NAME)-notes-doc.{aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,ins,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb}
distclean: clean
	rm -f oxnotes.bbx oxyear.bbx british-$(NAME).lbx $(NAME).pdf $(NAME)-preamble.tex $(NAME)-notes-doc.{tex,pdf} $(NAME).bib
inst: $(NAME).pdf clean
	sudo mkdir -p $(UTREE)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(UTREE)/source/latex/$(NAME)
	sudo cp oxnotes.bbx oxyear.bbx british-$(NAME).lbx $(UTREE)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(NAME)-notes-doc.{tex,pdf} $(NAME).bib $(UTREE)/doc/latex/$(NAME)
install: $(NAME).pdf clean
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(LOCAL)/source/latex/$(NAME)
	sudo cp oxnotes.bbx oxyear.bbx british-$(NAME).lbx $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(NAME)-notes-doc.{tex,pdf} $(NAME).bib $(LOCAL)/doc/latex/$(NAME)
workmf: $(NAME).pdf clean
	sudo mkdir -p $(WORKMF)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).{tex} $(WORKMF)/source/latex/$(NAME)
	sudo cp oxnotes.bbx oxyear.bbx british-$(NAME).lbx $(WORKMF)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(NAME)-notes-doc.{tex,pdf} $(NAME).bib $(WORKMF)/doc/latex/$(NAME)
zip: $(NAME).pdf $(NAME)-notes-doc.pdf clean
	mkdir $(TDIR)
	cp $(NAME).{tex,pdf} $(NAME)-notes-doc.pdf README.md Makefile oxnotes.bbx oxyear.bbx british-$(NAME).lbx $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
