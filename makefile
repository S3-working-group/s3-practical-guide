
CONFIG=config.yaml
GLOSSARY=glossary.yaml
PATTERNINDEX=pattern-index.yaml
SOURCE=src/
TMPFOLDER=tmp/

include make-conf

deckset:
	$(build-index)
	# build index database (add this line only for the English repo!!)
	mdslides build-index-db $(CONFIG) $(PATTERNINDEX)

	# build deckset presentation and add pattern index
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=img --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build deckset $(CONFIG) $(TMPFOLDER) $(TARGETFILE).md --template=templates/deckset-template.md  --glossary=$(GLOSSARY) --glossary-items=16
	# append pattern-index
	mdslides deckset-index $(PATTERNINDEX) $(TARGETFILE).md

revealjs:
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=text --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build revealjs $(CONFIG) $(TMPFOLDER) reveal.js/$(TARGETFILE).html --template=templates/revealjs-template.html  --glossary=$(GLOSSARY) --glossary-items=8

site:
	# build index database (add this line only for the English repo!!)
	mdslides build-index-db $(CONFIG) $(PATTERNINDEX)

	mdslides build jekyll $(CONFIG) $(SOURCE) docs/ --glossary=$(GLOSSARY) --template=docs/_templates/index.md --index=$(PATTERNINDEX)
	cd docs;jekyll build

wordpress:
	# join each pattern group into one md file to be used in wordpress
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=none --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build wordpress $(CONFIG) $(TMPFOLDER) web-out/ --footer=templates/wordpress-footer.md  --glossary=$(GLOSSARY)


epub:
	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) ebook/ --glossary=glossary.yaml --index=$(PATTERNINDEX) --section-prefix="$(SECTIONPREFIX)"
	# transclude all to one file 
	cd ebook; multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md
	cd ebook; multimarkdown --to=mmd --output=tmp-ebook-epub-compiled.md ebook-epub--master.md

	cd ebook; pandoc tmp-ebook-epub-compiled.md -f markdown -t epub3 -s -o ../$(TARGETFILE).epub

	# clean up
	cd ebook; rm tmp-*

ebook:
	# render an ebook as pdf
	
	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) ebook/ --glossary=glossary.yaml --index=$(PATTERNINDEX) --section-prefix="$(SECTIONPREFIX)"
	# transclude all to one file 
	cd ebook; multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md
	cd ebook; multimarkdown --to=mmd --output=tmp-ebook-epub-compiled.md ebook-epub--master.md
	
	cd ebook; multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd ebook; latexmk -pdf ebook-proof.tex 
	cd ebook; mv ebook-proof.pdf ../$(TARGETFILE)-ebook.pdf
	
	# clean up
	cd ebook; latexmk -C
	cd ebook; rm tmp-*

html:
	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) ebook/ --glossary=glossary.yaml --index=$(PATTERNINDEX)
	# transclude all to one file 
	cd ebook; multimarkdown --to=mmd --output=../docs/all.md single-page--master.md
	# clean up
	cd ebook; rm tmp-*

