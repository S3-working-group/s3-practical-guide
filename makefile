
CONFIG=content/structure.yaml
GLOSSARY=content/glossary.yaml
SOURCE=content/src
TMPFOLDER=tmp
TMPSUP = tmp/supporter-epub
LOC=content/localization.po
PRJ=config/project.yaml
MKTPL=mdslides template

# get language specific parameters
include config/make-conf

define update-make-conf
# update the make conf file from translations
$(MKTPL) templates/make-conf config/make-conf $(LOC) $(PRJ)
endef


make translations:
	$(MKTPL) templates/version.txt content/version.txt $(LOC) $(PRJ)
	# it's intentional this is just echoed
	echo "sudo crowdin --identity ~/crowdin-s3-patterns.yaml upload sources -b release-$$(cat content/version.txt) --dryrun"


site:
	# build jekyll site
	$(update-make-conf)

	# build content files
	mdslides build jekyll $(CONFIG) $(SOURCE) docs/ --glossary=$(GLOSSARY) --template=content/website/_templates/index.md --section-index-template=content/website/_templates/pattern-index.md --introduction-template=content/website/_templates/introduction.md

	# split introduction into intro and concepts/principles
	awk '{print >out}; /<!-- split here -->/{out="tmp/docs/concepts-and-principles-content.md"}' out=tmp/docs/introduction-content.md docs/introduction.md
	$(MKTPL) templates/docs/introduction.md $(TMPFOLDER)/docs/intro_tmpl.md $(LOC) $(PRJ)
	cd $(TMPFOLDER)/docs; multimarkdown --to=mmd --output=../../docs/introduction.md intro_tmpl.md
	$(MKTPL) templates/docs/concepts-and-principles.md $(TMPFOLDER)/docs/concepts_tmpl.md $(LOC) $(PRJ)
	cd $(TMPFOLDER)/docs; multimarkdown --to=mmd --output=../../docs/concepts-and-principles.md concepts_tmpl.md
	
	# prepare templates
	$(MKTPL) templates/docs/_layouts/default.html docs/_layouts/default.html $(LOC) $(PRJ)
	$(MKTPL) templates/docs/_layouts/plain.html docs/_layouts/plain.html $(LOC) $(PRJ)
	$(MKTPL) templates/docs/_config.yml docs/_config.yml $(LOC) $(PRJ)
	$(MKTPL) templates/docs/CNAME docs/CNAME $(LOC) $(PRJ)
	$(MKTPL) content/website/_includes/footer.html docs/_includes/footer.html $(LOC) $(PRJ)
	cp templates/docs/map.md docs/map.md
	$(MKTPL)  templates/docs/pattern-map.html docs/_includes/pattern-map.html $(LOC) $(PRJ)
	cp content/website/_includes/header.html docs/_includes/header.html

	# build the site
	cd docs;jekyll build

epub:
	# render an ebook as epub
	$(update-make-conf)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/epub--master.md $(TMPFOLDER)/ebook/epub--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=epub-compiled.md epub--master.md
	# render to epub
	cd $(TMPFOLDER)/ebook; pandoc epub-compiled.md -f markdown -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE).epub

supporter-epub:
	# render epub for supporter edition
	$(update-make-conf)

	# create description as html
	multimarkdown --to=html --output=tmp/store-description.html content/src/introduction/s3-overview-supporter-edition.md

	# render intro, chapters and appendix to separate md files
	mdslides build ebook content/structure-supporter-edition.yaml $(SOURCE) $(TMPSUP)/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/supporter-epub/master.md $(TMPSUP)/master.md $(LOC) $(PRJ)
	# prepare and copy metadata
	$(MKTPL) templates/supporter-epub/metadata.yaml $(TMPSUP)/metadata.yaml $(LOC) $(PRJ)
	cp templates/epub.css $(TMPSUP)/epub.css


htmlbook:
	# render an ebook as html book
	$(update-make-conf)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook content/structure-supporter-edition.yaml $(SOURCE) $(TMPFOLDER)/htmlbook/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/htmlbook--master.md $(TMPFOLDER)/htmlbook/htmlbook--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(TMPFOLDER)/htmlbook; multimarkdown --to=html --output=book.html htmlbook--master.md
	rm $(TMPFOLDER)/htmlbook/*.md
	cp templates/epub.css $(TMPFOLDER)/htmlbook
	-rm supporter-edition.zip
	cd $(TMPFOLDER)/htmlbook; zip  -r ../../supporter-edition *

ebook:
	# render an ebook as pdf (via LaTEX)
	$(update-make-conf)
	
	# render intro, chapters and appendix to separate md files (but without sectionprefix!)
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --no-section-prefix

	# copy md and LaTEX templates
	$(MKTPL) templates/ebook--master.md $(TMPFOLDER)/ebook/ebook--master.md $(LOC) $(PRJ)
	$(MKTPL) config/ebook.tex $(TMPFOLDER)/ebook/ebook.tex $(LOC) $(PRJ)
	$(MKTPL) config/ebook-style.sty $(TMPFOLDER)/ebook/ebook-style.sty $(LOC) $(PRJ)

	# make an index
	mdslides index latex $(CONFIG) $(TMPFOLDER)/ebook/tmp-index.md
	# transclude all to one file
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md

	cd $(TMPFOLDER)/ebook; multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd $(TMPFOLDER)/ebook; latexmk -pdf -xelatex -silent ebook.tex 
	cd $(TMPFOLDER)/ebook; mv ebook.pdf ../../$(TARGETFILE).pdf
	
	# clean up
	cd $(TMPFOLDER)/ebook; latexmk -C

single:
	$(update-make-conf)

	$(MKTPL) templates/single-page--master.md $(TMPFOLDER)/ebook/single-page--master.md $(LOC) $(PRJ)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=../../docs/all.md single-page--master.md

gitbook:
	mdslides build gitbook $(CONFIG) $(SOURCE) gitbook/ --glossary=$(GLOSSARY)

update:
	$(update-make-conf)

clean:
	# clean all generated content
	-rm -r docs/img
	-rm -r docs/_site
	-rm docs/*.md
	# take no risk here!
	-rm -r tmp

setup:
	# prepare temp folders and jekyll site
	$(update-make-conf)
	# prepare temp folders
	echo "this might produce error output if folders already exist"
	-mkdir -p $(TMPFOLDER)/ebook
	-mkdir -p $(TMPSUP)
	-mkdir -p $(TMPFOLDER)/web-out
	-mkdir -p $(TMPFOLDER)/docs
	-mkdir docs/_site
	
	# images for htmlbook
ifneq ("$(wildcard $(TMPFOLDER)/htmlbook/img)","")
	# take no risk here!
	rm -r tmp/htmlbook/img
endif 
	cp -r img $(TMPFOLDER)/htmlbook/img

	# images for supporter epub
ifneq ("$(wildcard $(TMPSUP)/img)","")
	# take no risk here!
	rm -r $(TMPSUP)/img
endif 
	cp -r img $(TMPSUP)/img


	# clean up and copy images do to docs folder
ifneq ("$(wildcard docs/img)","")
	rm -r docs/img
endif
	cp -r img docs/img
ifneq ("$(wildcard gitbook/img)","")
	# rm -r gitbook/img
endif
	# cp -r img gitbook/img

# --- legacy commands ----

deckset-:
	$(update-make-conf)

	# build deckset presentation and add pattern index
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=img --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	
	$(MKTPL) templates/deckset-template.md $(TMPFOLDER)/deckset-template.md $(LOC) $(PRJ)
	mdslides build deckset $(CONFIG) $(TMPFOLDER) $(TARGETFILE).md --template=$(TMPFOLDER)/deckset-template.md  --glossary=$(GLOSSARY) --glossary-items=16
	# append pattern-index
	mdslides index deckset $(CONFIG) $(TARGETFILE).md --append

revealjs-:
	$(update-make-conf)

	$(MKTPL) templates/revealjs-template.html $(TMPFOLDER)/revealjs-template.html $(LOC) $(PRJ)

	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=text --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build revealjs $(CONFIG) $(TMPFOLDER) docs/slides.html --template=$(TMPFOLDER)/revealjs-template.html  --glossary=$(GLOSSARY) --glossary-items=8

wordpress-:
	# join each pattern group into one md file to be used in wordpress
	$(update-make-conf)
ifeq ("$(wildcard $(TMPFOLDER)/web-out)","")
	mkdir $(TMPFOLDER)/web-out
endif 
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=none --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build wordpress $(CONFIG) $(TMPFOLDER) $(TMPFOLDER)/web-out/ --footer=templates/wordpress-footer.md  --glossary=$(GLOSSARY)
