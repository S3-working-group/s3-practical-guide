TMP=tmp
PROJECT=config/project.yaml

# get language specific parameters
include config/local-conf

make translations:
	mdtemplate default $(PROJECT) templates/version.txt content/version.txt
	# it's intentional this is just echoed
	echo "sudo crowdin upload sources --dryrun"

version:
	mdtemplate default $(PROJECT) templates/version.txt content/version.txt

site:
	# build jekyll site
	mdbuild jekyll $(PROJECT) -vv
	mdbuild all-in-one-jekyll-page $(PROJECT) -vv
	cd docs;jekyll build

rebuild-site:
	mdbuild jekyll $(PROJECT) -vv
	mdbuild all-in-one-jekyll-page $(PROJECT) -vv

serve-site:
	open http://127.0.0.1:4000/
	# serve jekyll site
	cd docs;jekyll serve
	# release the port if something went wrong:
	# ps aux |grep jekyll |awk '{print $2}' | xargs kill -9

serve-lan:
	open http://192.168.1.51:4000/
	# serve jekyll site
	cd docs;jekyll serve s -H 192.168.1.51
	# release the port if something went wrong:
	# ps aux |grep jekyll |awk '{print $2}' | xargs kill -9

debug:
	# build with debug output (for quickly testing changes to structure.yaml or project.yaml)
	mdbuild all-in-one-jekyll-page $(PROJECT) -vvvv

epub:
	# render an ebook as epub
	echo $(TARGETFILE)
	mdbuild epub $(PROJECT) -vv
	cd $(TMP); pandoc epub-compiled.md -f markdown -t epub3 --toc --toc-depth=3 -s -o ../$(TARGETFILE).epub

docx:
	# render an ebook as epub
	echo $(TARGETFILE)
	mdbuild epub $(PROJECT) -vv
	cd $(TMP); pandoc epub-compiled.md -f markdown -t docx --toc --toc-depth=3 -s -o ../$(TARGETFILE).docx

supporter-epub:
	# render epub for supporter edition
	# mdbuild supporter-epub $(PROJECT) -vv

	# prepare description html and add to metadata
	pandoc content/src/introduction/s3-overview-supporter-edition.md -f markdown_mmd -t html -o $(TMP)/description.html
	cd $(TMP); tr -d "\n" <description.html >description-one-line.html
	cd $(TMP); awk 'BEGIN{RS = "\n\n+" getline l < "description-one-line.html"}/htmldescription/{gsub("htmldescription",l)}1' supporter-edition-metadata.yaml >metadata-full.yaml

	# make epub via pandoc
	# cd $(TMP); pandoc supporter-epub-compiled.md -f markdown --metadata-file=metadata-full.yaml -t epub3 --toc --toc-depth=3 -s -o ../$(TARGETFILE)-supporter-edition.epub

ebook:
	# render an ebook as pdf (via LaTEX)
	mdbuild ebook $(PROJECT) -vv
	
	cd $(TMP); multimarkdown --to=latex --output=ebook-compiled.tex ebook-compiled.md
	cd $(TMP); latexmk -pdf -xelatex -silent ebook.tex 

	cd $(TMP); mv ebook.pdf ../$(TARGETFILE).pdf
	
	# clean up
	cd $(TMP); latexmk -C

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
	echo "this might produce error output if folders already exist"
	-mkdir -p $(TMP)
	-mkdir docs/_site

	# copy images to temp folder
ifneq ("$(wildcard $(TMP)/img)","")
	# take no risk here!
	rm -r $(TMP)/img
endif
	cp -r img $(TMP)/img
	cp templates/covers/* $(TMP)/img
	cp templates/ebook-cover.pdf $(TMP)

	# clean up and copy images do to docs folder
ifneq ("$(wildcard docs/img)","")
	rm -r docs/img
endif
	cp -r img docs/img
