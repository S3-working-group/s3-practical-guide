# Release Process for the Practical Guide

Now that we are using quite a few  output formats and translated versions it makes sense to have some form of documentation for the release process of the practical guide. 

## 1 . S3-Illustrations Repository

1. export all illustrations as png from the S3 illustration repository and integrate into the practical guide repo
2. make sure illustration repository is published so that the pattern map illustration on the website is the current version
3. export translatable texts for illustrations and upload to crowdin

## 2. S3 Practical Guide Repository

1. bump the date in `config/project.yaml`
2. make a clean build for all fully automated formats  and the Deckset source (using `./build.sh`)
3. run `make ebook` again (or even twice) so that the ebook is built
4. edit Deckset source: remove link on title page (otherwise the headline is aligned left
5. export Deckset slide deck (16:9, with S3-Open-Theme v0.3) as PDF and PNG
6. export Deckset slides (4:3) as A4 PDF
7. move release artifacts to directory `release`
8 Upload 3 PDFs (deckset 16:9 and A4, and ebook), 1 ePub and 1 ZIP (Deckset PNG) to <ftp://sociocracy30.org/_res/practical-guide>

## 3. Refresh Translations

1. Crowdin: Build and download all translations (as a backup)
2. Upload previous version of the sources (typically in develop) to a crowdin branch called `release-YYYY-MM-DD`
3. merge release branch into develop
4. upload current sources to crowdin
5. manually remove all files from crowdin that have been renamed or deleted in the practical guide

## 4. Update S3 Website

1. Bump the date on <https://sociocracy30.org/guide/>, the links should stay the same.
2. Manually update Glossary, Changelog and Acknowledgements. The simplest way to update these is to copy the content out of the Deckset-file and manually remove the headlines.
	- Changelog: <https://sociocracy30.org/guide/changelog/>
	- Glossary: <https://sociocracy30.org/guide/glossary/>
	- Acknowledgements: <https://sociocracy30.org/guide/acknowledgements/>

## 5. Publish Patterns Microsite

1. merge release into master 
2. tag with `release-YYYY-MM-DD`
3. push to GitHub