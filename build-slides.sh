
# build deckset
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=img
mdslides build deckset s3-practical-guide.yaml tmp/ s3-practical-guide.md --template=templates/deckset-template.md
# append pattern-index
python build_index.py >>s3-practical-guide.md


# build reveal.js
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=text
mdslides build revealjs s3-practical-guide.yaml  tmp/ reveal.js/s3-practical-guide.html --template=templates/revealjs-template.html

# build wordpress output
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=none
mdslides build wordpress s3-practical-guide.yaml tmp/ web-out/ --footer=templates/wordpress-footer.md