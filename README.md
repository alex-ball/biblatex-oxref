# biblatex-oxref: Biblatex styles inspired by the *Oxford Guide to Style*

This bundle provides four [biblatex] styles that implement (some of) the
stipulations and examples provided by the 2014 *New Hart's Rules* and the 2002
*Oxford Guide to Style*:

  * `oxnotes` is a style similar to the standard `verbose`,
    intended for use with footnotes;
  * `oxnum` is a style similar to the standard `numeric`,
    intended for use with numeric in-text citations.
  * `oxalph` is a style similar to the standard `alphabetic`,
    intended for use with alphabetic in-text citations.
  * `oxyear` is a style similar to the standard `authoryear`,
    intended for use with parenthetical in-text citations.

[biblatex]: http://ctan.org/pkg/biblatex

## Installation

### Dependencies

To compile the documentation you will need to have the [minted] package working,
which in turn relies on Python 2.6+ and Pygments. See the documentation of that
package for details.

### Managed way

The latest stable release of the biblatex-oxref bundle has been packaged for
TeX Live and MiKTeX. If you are running TeX Live and have `tlmgr` installed, you
can install the bundle simply by running `tlmgr install biblatex-oxref`. If you
are running MiKTeX, you can install the bundle by running
`mpm --install=biblatex-oxref`. Both `tlmgr` and `mpm` have GUI versions that
you might find friendlier.

### Automated way

A makefile is provided which you can use with the Make utility on
UNIX-like systems:

  * Running `make source` generates the derived files
      - README.md
      - oxref.bbx, oxnotes.bbx, oxnotes-ibid.bbx, oxnotes-note.bbx,
        oxnotes-inote.bbx, oxnotes-trad1.bbx, oxnotes-trad2.bbx,
        oxnotes-trad3.bbx, oxyear.bbx, oxnum.bbx, oxalph.bbx
      - oxnotes.cbx, oxnotes-ibid.cbx, oxnotes-note.cbx, oxnotes-inote.cbx,
        oxnotes-trad1.cbx, oxnotes-trad2.cbx, oxnotes-trad3.cbx, oxyear.cbx,
        oxnum.cbx, oxalph.cbx
      - american-oxref.lbx, british-oxref.lbx, english-oxref.lbx
      - oxnotes.dbx, oxnotes-ibid.dbx, oxnotes-note.dbx, oxnotes-inote.dbx,
        oxnotes-trad1.dbx, oxnotes-trad2.dbx, oxnotes-trad3.dbx, oxyear.dbx,
        oxnum.dbx, oxalph.dbx
      - oxref.bib
      - oxref.ins
      - oxnotes-doc.tex, oxyear-doc.tex, oxnum-doc.tex, oxalph-doc.tex

  * Running `make` generates the above files and also oxref.pdf,
    oxnotes-doc.pdf, oxyear-doc.pdf, oxnum-doc.pdf and oxalph-doc.pdf.

  * Running `make inst` installs the files in the user's TeX tree.
    You can undo this with `make uninst`.

  * Running `make install` installs the files in the local TeX tree.
    You can undo this with `make uninstall`.

  * Running `make clean` removes auxiliary files from the working directory.

  * Running `make distclean` removes the generated files from the working
    directory as well.

### Manual way

To install the bundle from scratch, follow these instructions. If you have
downloaded the zip file from the [Releases] page on GitHub, you can skip the
first two steps.

 1. Run `luatex oxref.dtx` to generate the source files. (You can safely skip
    this step if you are confident about step 2.)

 2. Compile oxref.dtx, oxnotes-doc.tex, oxyear-doc.tex, and oxnum-doc.tex with
    LuaLaTeX and Biber to generate the documentation. You will need to enable
    shell escape so that [minted] can typeset the listings.

 3. Move the files to your TeX tree as follows:
      - `source/latex/biblatex-oxref`:
        oxref.dtx,
        (oxref.ins)
      - `tex/latex/biblatex-oxref`:
        american-oxref.lbx,
        british-oxref.lbx,
        english-oxref.lbx,
        oxalph.bbx,
        oxalph.cbx,
        oxalph.dbx,
        oxnotes.bbx,
        oxnotes.cbx,
        oxnotes.dbx,
        oxnotes-ibid.bbx,
        oxnotes-ibid.cbx,
        oxnotes-ibid.dbx,
        oxnotes-inote.bbx,
        oxnotes-inote.cbx,
        oxnotes-inote.dbx,
        oxnotes-note.bbx,
        oxnotes-note.cbx,
        oxnotes-note.dbx,
        oxnotes-trad1.bbx,
        oxnotes-trad1.cbx,
        oxnotes-trad1.dbx,
        oxnotes-trad2.bbx,
        oxnotes-trad2.cbx,
        oxnotes-trad2.dbx,
        oxnotes-trad3.bbx,
        oxnotes-trad3.cbx,
        oxnotes-trad3.dbx,
        oxnum.bbx,
        oxnum.cbx,
        oxnum.dbx,
        oxref.bbx,
        oxyear.bbx,
        oxyear.cbx,
        oxyear.dbx
      - `doc/latex/biblatex-oxref`:
        README.md,
        oxalph-doc.pdf,
        oxalph-doc.tex,
        oxnotes-doc.pdf,
        oxnotes-doc.tex,
        oxnum-doc.pdf,
        oxnum-doc.tex,
        oxref.bib,
        oxref.pdf,
        oxyear-doc.pdf,
        oxyear-doc.tex

 4. You may then have to update your installation's file name database
    before TeX and friends can see the files.

[Releases]: https://github.com/alex-ball/biblatex-oxref/releases
[minted]: http://ctan.org/pkg/minted

## Licence

Copyright 2016–2021 Alex Ball.

This work consists of the documented LaTeX file oxref.dtx and a Makefile.

The text files contained in this work may be distributed and/or modified
under the conditions of the [LaTeX Project Public License (LPPL)][lppl],
either version 1.3c of this license or (at your option) any later
version.

This work is ‘maintained’ (as per LPPL maintenance status) by [Alex Ball][me].

[lppl]: http://www.latex-project.org/lppl.txt "LaTeX Project Public License (LPPL)"
[me]: https://alexball.me.uk/ "Alex Ball"

