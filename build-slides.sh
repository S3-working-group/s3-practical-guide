# build deckset
s3slides build deckset s3-all-patterns-explained.yaml src/ s3-all-patterns-explained.md --chapter-title=img --template=templates/deckset-template.md

# build reveal.js
s3slides build revealjs s3-all-patterns-explained.yaml  src/ reveal.js/s3-all-patterns-explained.html --chapter-title=text --template=templates/revealjs-template.html

# build wordpress output
s3slides build wordpress s3-all-patterns-explained.yaml src/ web-out --footer=templates/wordpress-footer.md