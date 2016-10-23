NAME  = oxref
STY1  = oxnotes
STY2  = oxyear
SHELL = bash
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t tmp.XXXXXXXXXX)
TDIR  = $(TEMP)/$(NAME)
VERS  = $(shell ltxfileinfo -v $(NAME).dtx)
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)
all:	$(NAME).pdf $(STY1)-doc.pdf $(STY2)-doc.pdf clean
	@exit 0
$(STY1)-doc.tex $(STY2)-doc.tex $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx: $(NAME).dtx
	luatex -interaction=nonstopmode $(NAME).dtx >/dev/null
$(NAME).pdf: $(NAME).dtx $(NAME).bbx $(STY1).bbx $(STY1).cbx british-$(NAME).lbx
	latexmk -silent -lualatex -shell-escape -interaction=nonstopmode $(NAME).dtx >/dev/null
$(STY1)-doc.pdf: $(STY1)-doc.tex $(NAME).bbx $(STY1).bbx $(STY1).cbx british-$(NAME).lbx
	latexmk -silent -lualatex -shell-escape -interaction=nonstopmode $(STY1)-doc.tex >/dev/null
$(STY2)-doc.pdf: $(STY2)-doc.tex $(NAME).bbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx
	latexmk -silent -lualatex -shell-escape -interaction=nonstopmode $(STY2)-doc.tex >/dev/null
clean:
	rm -f {$(NAME),$(STY1)-doc,$(STY2)-doc}.{aux,bbl,bcf,blg,doc,fdb_latexmk,fls,glo,gls,hd,idx,ilg,ind,ins,listing,log,nav,out,run.xml,snm,synctex.gz,toc,vrb}
	rm -f {$(STY1),$(STY2),british-$(NAME)}.doc
	rm -rf _minted-$(NAME)
distclean: clean
	rm -f $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib
inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/latex/$(NAME)
	cp $(NAME).dtx $(UTREE)/source/latex/$(NAME)
	cp $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(UTREE)/tex/latex/$(NAME)
	cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(UTREE)/doc/latex/$(NAME)
install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/latex/$(NAME)
	sudo cp $(NAME).dtx $(LOCAL)/source/latex/$(NAME)
	sudo cp $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(LOCAL)/tex/latex/$(NAME)
	sudo cp $(NAME).pdf $(NAME)-preamble.tex $(STY1)-doc.{tex,pdf} $(STY2)-doc.{tex,pdf} $(NAME).bib $(LOCAL)/doc/latex/$(NAME)
zip: $(NAME).pdf $(STY1)-doc.pdf $(STY2)-doc.pdf clean
	mkdir $(TDIR)
	cp $(NAME).{dtx,pdf} $(STY1)-doc.pdf $(STY2)-doc.pdf README.md Makefile $(NAME).bbx $(STY1).bbx $(STY1).cbx $(STY2).bbx $(STY2).cbx british-$(NAME).lbx $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
