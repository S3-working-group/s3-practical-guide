
CONFIG=content/structure.yaml
GLOSSARY=content/glossary.yaml
SOURCE=content/src
TMPFOLDER=tmp
TMPSUP = tmp/supporter-epub
EBOOK_TMP = tmp/ebook
DOCS_TMP = tmp/docs
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
	awk '{print >out}; /<!-- split here -->/{out="$(DOCS_TMP)/concepts-and-principles-content.md"}' out=$(DOCS_TMP)/introduction-content.md docs/introduction.md
	$(MKTPL) templates/website/introduction.md $(DOCS_TMP)/intro_tmpl.md $(LOC) $(PRJ)
	cd $(DOCS_TMP); multimarkdown --to=mmd --output=../../docs/introduction.md intro_tmpl.md
	$(MKTPL) content/website/_templates/concepts-and-principles.md $(DOCS_TMP)/concepts_tmpl.md $(LOC) $(PRJ)
	cd $(DOCS_TMP); multimarkdown --to=mmd --output=../../docs/concepts-and-principles.md concepts_tmpl.md
	
	# prepare templates
	$(MKTPL) templates/website/_layouts/default.html docs/_layouts/default.html $(LOC) $(PRJ)
	$(MKTPL) templates/website/_layouts/plain.html docs/_layouts/plain.html $(LOC) $(PRJ)
	$(MKTPL) templates/website/_config.yml docs/_config.yml $(LOC) $(PRJ)
	$(MKTPL) templates/website/CNAME docs/CNAME $(LOC) $(PRJ)
	$(MKTPL) content/website/_includes/footer.html docs/_includes/footer.html $(LOC) $(PRJ)
	cp templates/website/map.md docs/map.md
	$(MKTPL) templates/website/pattern-map.html docs/_includes/pattern-map.html $(LOC) $(PRJ)
	cp content/website/_includes/header.html docs/_includes/header.html
	cp content/website/_templates/404.md docs/404.md

	# build the single page version
	$(MKTPL) templates/single-page--master.md $(EBOOK_TMP)/single-page--master.md $(LOC) $(PRJ)
	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(EBOOK_TMP)/ --glossary=$(GLOSSARY)
	# transclude all to one file 
	cd $(EBOOK_TMP); multimarkdown --to=mmd --output=../../docs/all.md single-page--master.md

	# build the site
	cd docs;jekyll build

epub:
	# render an ebook as epub
	$(update-make-conf)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(EBOOK_TMP)/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/epub--master.md $(EBOOK_TMP)/epub--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(EBOOK_TMP); multimarkdown --to=mmd --output=epub-compiled.md epub--master.md
	# render to epub
	cd $(EBOOK_TMP); pandoc epub-compiled.md -f markdown -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE).epub

supporter-epub:
	# render epub for supporter edition
	$(update-make-conf)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook content/structure-supporter-edition.yaml $(SOURCE) $(TMPSUP)/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template, metadata, CSS and cover
	$(MKTPL) templates/supporter-epub/master.md $(TMPSUP)/master.md $(LOC) $(PRJ)
	$(MKTPL) templates/supporter-epub/metadata.yaml $(TMPSUP)/metadata.yaml $(LOC) $(PRJ)
	cp templates/epub.css $(TMPSUP)/epub.css
	cp templates/covers/s3-practical-guide-cover-supporter-edition-70dpi.png $(TMPSUP)/cover.png

	pandoc content/src/introduction/s3-overview-supporter-edition.md -f markdown_mmd -t html -o $(TMPSUP)/description.html
	cd $(TMPSUP); tr -d "\n" <description.html >description-one-line.html
	cd $(TMPSUP); awk 'BEGIN{RS = "\n\n+" getline l < "description-one-line.html"}/htmldescription/{gsub("htmldescription",l)}1' metadata.yaml >metadata-full.yaml

	# transclude all to one file (rendering to html or mmd yields exactly the same epub)
	cd $(TMPSUP); multimarkdown --to=mmd --output=epub-compiled.md master.md
	# make epub via pandoc
	cd $(TMPSUP); pandoc epub-compiled.md -f markdown --metadata-file=metadata-full.yaml -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE)-supporter-edition.epub

ebook:
	# render an ebook as pdf (via LaTEX)
	$(update-make-conf)
	
	# render intro, chapters and appendix to separate md files (but without sectionprefix!)
	mdslides build ebook $(CONFIG) $(SOURCE) $(EBOOK_TMP)/ --glossary=$(GLOSSARY) --no-section-prefix

	# copy md and LaTEX templates
	$(MKTPL) templates/ebook--master.md $(EBOOK_TMP)/ebook--master.md $(LOC) $(PRJ)
	$(MKTPL) config/ebook.tex $(EBOOK_TMP)/ebook.tex $(LOC) $(PRJ)
	$(MKTPL) config/ebook-style.sty $(EBOOK_TMP)/ebook-style.sty $(LOC) $(PRJ)

	# make an index
	mdslides index latex $(CONFIG) $(EBOOK_TMP)/tmp-index.md
	# transclude all to one file
	cd $(EBOOK_TMP); multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md

	cd $(EBOOK_TMP); multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd $(EBOOK_TMP); latexmk -pdf -xelatex -silent ebook.tex 

	# merge with cover
	cd $(EBOOK_TMP); gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf ../../templates/ebook-cover.pdf ebook.pdf

	cd $(EBOOK_TMP); mv merged.pdf ../../$(TARGETFILE).pdf
	
	# clean up
	cd $(EBOOK_TMP); latexmk -C

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
	-mkdir -p $(EBOOK_TMP)
	-mkdir -p $(DOCS_TMP)
	-mkdir -p $(TMPSUP)
	-mkdir docs/_site

	# update version number in content
	$(MKTPL) templates/version.txt content/version.txt $(LOC) $(PRJ)

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
