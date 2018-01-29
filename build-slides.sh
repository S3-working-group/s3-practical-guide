# build deckset
## build index database
mdslides build-index-db config.yaml pattern-index.yaml

## compile slides
mdslides compile config.yaml src/ tmp/ --chapter-title=img --glossary=glossary.yaml --chapter-prefix=" Pattern %(chapter)s.%(section)s:"
## build presentation
mdslides build deckset config.yaml tmp/ s3-practical-guide.md --template=templates/deckset-template.md  --glossary=glossary.yaml --glossary-items=16
## append pattern-index
mdslides deckset-index pattern-index.yaml s3-practical-guide.md

# build reveal.js
mdslides compile config.yaml src/ tmp/ --chapter-title=text --glossary=glossary.yaml --chapter-prefix=" Pattern %(chapter)s.%(section)s:"
mdslides build revealjs config.yaml  tmp/ reveal.js/s3-practical-guide.html --template=templates/revealjs-template.html  --glossary=glossary.yaml  --glossary-items=8

# build wordpress output
mdslides compile config.yaml src/ tmp/ --chapter-title=none --glossary=glossary.yaml --chapter-prefix=" Pattern %(chapter)s.%(section)s:"
mdslides build wordpress config.yaml tmp/ web-out/ --footer=templates/wordpress-footer.md  --glossary=glossary.yaml