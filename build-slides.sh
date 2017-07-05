
# build deckset
s3slides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=img
s3slides build deckset s3-all-patterns-explained.yaml tmp/ s3-all-patterns-explained.md --template=templates/deckset-template.md

# build reveal.js
s3slides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=text
s3slides build revealjs s3-all-patterns-explained.yaml  tmp/ reveal.js/s3-all-patterns-explained.html --template=templates/revealjs-template.html

# build wordpress output
s3slides compile s3-all-patterns-explained.yaml src/ tmp/ --chapter-title=none
s3slides build wordpress s3-all-patterns-explained.yaml tmp/ web-out/ --footer=templates/wordpress-footer.md