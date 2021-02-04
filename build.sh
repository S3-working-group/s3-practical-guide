# clean everything, then build the site, the epub and the pdf
make clean
make setup
# for translations, remove or comment the targets that cannot be created for that language
make site
make epub
make ebook
make version
