# build deckset
s3slides build deckset s3patterns.yml src/ s3-all-patterns-explained.md --group-title=img

# build reveal.js
s3slides build revealjs s3patterns.yml  src/ reveal.js/s3-all-patterns-explained.html --group-title=text

# build wordpress output
s3slides build wordpress s3patterns.yml src/ web-out --footer=templates/wordpress-footer.md