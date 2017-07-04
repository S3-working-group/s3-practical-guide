# build deckset
s3slides build deckset s3patterns.yml src/ s3-all-patterns-explained.md --group-title=img

# build reveal.js
#s3slides build revealjs s3patterns.yml  src/ reveal.js/slides.html 