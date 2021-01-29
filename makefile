
TMPFOLDER=tmp
TMPSUP = tmp/supporter-epub
EBOOK_TMP = tmp/ebook
DOCS_TMP = tmp/docs
PROJECT=config/project.yaml
MKTPL=mdslides template

# get language specific parameters
include config/local-conf

make translations:
	$(MKTPL) templates/version.txt content/version.txt $(LOC) $(PRJ)
	# it's intentional this is just echoed
	echo "sudo crXXXXowdin --identity ~/crowdin-s3-patterns.yaml upload sources -b release-$$(cat content/version.txt) --dryrun"

site:
	# build jekyll site
	mdbuild jekyll $(PROJECT) -vv
	mdbuild all-in-one-jekyll-page $(PROJECT) -vv
	cd docs;jekyll build

single:
	mdbuild all-in-one-jekyll-page $(PROJECT) -vv

epub:
	# render an ebook as epub

	mdbuild epub $(PROJECT) -vv

# 	# transclude all to one file 
# 	cd $(EBOOK_TMP); multimarkdown --to=mmd --output=epub-compiled.md epub--master.md
# 	# render to epub
# 	cd $(EBOOK_TMP); pandoc epub-compiled.md -f markdown -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE).epub

supporter-epub:
	# render epub for supporter edition
# 	$(update-make-conf)

# 	# render intro, chapters and appendix to separate md files
# 	mdslides build ebook content/structure-supporter-edition.yaml $(SOURCE) $(TMPSUP)/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

# 	# prepare and copy template, metadata, CSS and cover
# 	$(MKTPL) templates/supporter-epub/master.md $(TMPSUP)/master.md $(LOC) $(PRJ)
# 	$(MKTPL) templates/supporter-epub/metadata.yaml $(TMPSUP)/metadata.yaml $(LOC) $(PRJ)
# 	cp templates/epub.css $(TMPSUP)/epub.css
# 	cp templates/covers/s3-practical-guide-cover-supporter-edition-70dpi.png $(TMPSUP)/cover.png

# 	pandoc content/src/introduction/s3-overview-supporter-edition.md -f markdown_mmd -t html -o $(TMPSUP)/description.html
# 	cd $(TMPSUP); tr -d "\n" <description.html >description-one-line.html
# 	cd $(TMPSUP); awk 'BEGIN{RS = "\n\n+" getline l < "description-one-line.html"}/htmldescription/{gsub("htmldescription",l)}1' metadata.yaml >metadata-full.yaml

# 	# transclude all to one file (rendering to html or mmd yields exactly the same epub)
# 	cd $(TMPSUP); multimarkdown --to=mmd --output=epub-compiled.md master.md
# 	# make epub via pandoc
# 	cd $(TMPSUP); pandoc epub-compiled.md -f markdown --metadata-file=metadata-full.yaml -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE)-supporter-edition.epub

ebook:
	# render an ebook as pdf (via LaTEX)
	mdbuild ebook $(PROJECT) -vv
	
	cd $(EBOOK_TMP); multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd $(EBOOK_TMP); latexmk -pdf -xelatex -silent ebook.tex 

	# merge with cover
	cd $(EBOOK_TMP); gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf ../../templates/ebook-cover.pdf ebook.pdf

	cd $(EBOOK_TMP); mv merged.pdf ../../$(TARGETFILE).pdf
	
	# clean up
	cd $(EBOOK_TMP); latexmk -C

gitbook:
	# mdslides build gitbook $(CONFIG) $(SOURCE) gitbook/ --glossary=$(GLOSSARY)

clean:
	# clean all generated content
	-rm -r docs/img
	-rm -r docs/_site
	-rm docs/*.md
	# take no risk here!
	-rm -r tmp

setup:
	# prepare temp folders and jekyll site
	# prepare temp folders
	echo "this might produce error output if folders already exist"
	-mkdir -p $(EBOOK_TMP)
	-mkdir -p $(DOCS_TMP)
	-mkdir -p $(TMPSUP)
	-mkdir docs/_site

	# images for ebook
ifneq ("$(wildcard $(EBOOK_TMP)/img)","")
	rm -r $(EBOOK_TMP)/img
endif
	cp -r img $(EBOOK_TMP)/img
	cp templates/covers/* $(EBOOK_TMP)/img

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
