
# build deckset
mdslides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=img
mdslides build deckset s3-all-patterns-explained.yaml tmp/ s3-all-patterns-explained.md --template=templates/deckset-template.md

# build reveal.js
mdslides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=text
mdslides build revealjs s3-all-patterns-explained.yaml  tmp/ reveal.js/s3-all-patterns-explained.html --template=templates/revealjs-template.html

# build wordpress output
mdslides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=none
mdslides build wordpress s3-all-patterns-explained.yaml tmp/ web-out/ --footer=templates/wordpress-footer.md