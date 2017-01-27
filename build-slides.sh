
# build reveal.js
s3tools slides s3patterns.yml --reveal --target=reveal.js/slides.html src/

# build deckset
s3tools slides s3patterns.yml --deckset --target=slides.md src/