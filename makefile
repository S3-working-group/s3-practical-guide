
CONFIG=templates/structure.yaml
GLOSSARY=content/glossary.yaml
PATTERNINDEX=content/pattern-index.yaml
SOURCE=content/src
TMPFOLDER=tmp
LOC=content/localization.po
PRJ=config/project.yaml
MKTPL=mdslides template

# get language specific parameters
include config/make-conf

define update-make-conf
# update the make conf file from translations
$(MKTPL) templates/make-conf config/make-conf $(LOC) $(PRJ)
endef

define build-index-db
# build the index database that is then translated into localized versions
mdslides build-index-db $(CONFIG) $(PATTERNINDEX)
endef

define prepare-ebook
# render intro, chapters and appendix to separate md files
mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --index=$(PATTERNINDEX) --section-prefix="$(SECTIONPREFIX)"
endef


deckset:
	$(update-make-conf)

ifeq "$(BUILD_INDEX)" "YES"
	# build index database (only for the English repo!!)
	$(build-index-db)
endif
	# build deckset presentation and add pattern index
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=img --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	
	$(MKTPL) templates/deckset-template.md $(TMPFOLDER)/deckset-template.md $(LOC) $(PRJ)
	mdslides build deckset $(CONFIG) $(TMPFOLDER) $(TARGETFILE).md --template=$(TMPFOLDER)/deckset-template.md  --glossary=$(GLOSSARY) --glossary-items=16
	# append pattern-index
	mdslides deckset-index $(PATTERNINDEX) $(TARGETFILE).md

revealjs:
	$(update-make-conf)

	$(MKTPL) templates/revealjs-template.html $(TMPFOLDER)/revealjs-template.html $(LOC) $(PRJ)

	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=text --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build revealjs $(CONFIG) $(TMPFOLDER) docs/slides.html --template=$(TMPFOLDER)/revealjs-template.html  --glossary=$(GLOSSARY) --glossary-items=8

site:
	# build jekyll site
	$(update-make-conf)

	# prepare templates
	$(MKTPL) templates/docs/_layouts/default.html docs/_layouts/default.html $(LOC) $(PRJ)
	$(MKTPL) templates/docs/_config.yml docs/_config.yml $(LOC) $(PRJ)
	$(MKTPL) templates/docs/CNAME docs/CNAME $(LOC) $(PRJ)
	$(MKTPL) content/website/_includes/footer.html docs/_includes/footer.html $(LOC) $(PRJ)
	cp content/website/_includes/header.html docs/_includes/header.html

ifeq "$(BUILD_INDEX)" "YES"
	# build index database (only for the English repo!!)
	$(build-index-db)
endif
	mdslides build jekyll $(CONFIG) $(SOURCE) docs/ --glossary=$(GLOSSARY) --template=content/website/_templates/index.md --index=$(PATTERNINDEX)
	cd docs;jekyll build

wordpress:
	# join each pattern group into one md file to be used in wordpress
	$(update-make-conf)
ifeq ("$(wildcard $(TMPFOLDER)/web-out)","")
	mkdir $(TMPFOLDER)/web-out
endif 
	mdslides compile $(CONFIG) $(SOURCE) $(TMPFOLDER) --chapter-title=none --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"
	mdslides build wordpress $(CONFIG) $(TMPFOLDER) $(TMPFOLDER)/web-out/ --footer=templates/wordpress-footer.md  --glossary=$(GLOSSARY)

epub:
	# render an ebook as epub
	$(update-make-conf)

	$(prepare-ebook)
	# prepare and copy template
	$(MKTPL) templates/epub--master.md $(TMPFOLDER)/ebook/epub--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=epub-compiled.md epub--master.md
	# render to epub
	cd $(TMPFOLDER)/ebook; pandoc epub-compiled.md -f markdown -t epub3 -s -o ../../$(TARGETFILE).epub

ebook:
	# render an ebook as pdf (via LaTEX)
	$(update-make-conf)
	$(prepare-ebook)

	# copy md and LaTEX templates
	$(MKTPL) templates/ebook--master.md $(TMPFOLDER)/ebook/ebook--master.md $(LOC) $(PRJ)
	$(MKTPL) config/ebook.tex $(TMPFOLDER)/ebook/ebook.tex $(LOC) $(PRJ)
	$(MKTPL) config/ebook-style.sty $(TMPFOLDER)/ebook/ebook-style.sty $(LOC) $(PRJ)

	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md

	cd $(TMPFOLDER)/ebook; multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd $(TMPFOLDER)/ebook; latexmk -pdf -silent ebook.tex 
	cd $(TMPFOLDER)/ebook; mv ebook.pdf ../../$(TARGETFILE)-ebook.pdf
	
	# clean up
	cd $(TMPFOLDER)/ebook; latexmk -C

single:
	$(update-make-conf)

	$(MKTPL) templates/single-page--master.md $(TMPFOLDER)/ebook/single-page--master.md $(LOC) $(PRJ)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --index=$(PATTERNINDEX)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=../../docs/all.md single-page--master.md

update:
	$(update-make-conf)

clean:
	# clean all generated content
	-rm -r docs/img
	-rm -r docs/_site
	-rm docs/*.md
	-rm -r $(TMPFOLDER)

setup:
	# prepare temp folders and jekyll site
	$(update-make-conf)
	# prepare temp folders
	echo "this might produce error output if folders already exist"
	-mkdir -p $(TMPFOLDER)/ebook
	-mkdir -p $(TMPFOLDER)/web-out
	-mkdir docs/_site
ifeq ("$(wildcard $(TMPFOLDER)/ebook/img)","")
	cd $(TMPFOLDER)/ebook; ln -s ../../img
endif 
	# clean up and copy images do to docs folder
ifneq ("$(wildcard docs/img)","")
	rm -r docs/img
endif
	cp -r img docs/img
