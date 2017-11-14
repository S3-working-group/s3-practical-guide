# build deckset
## build index database
mdslides build-index-db s3-practical-guide.yaml pattern-index.yaml

## compile slides
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=img --glossary=glossary.yaml
## build presentation
mdslides build deckset s3-practical-guide.yaml tmp/ s3-practical-guide.md --template=templates/deckset-template.md  --glossary=glossary.yaml --glossary-items=16
## append pattern-index
mdslides deckset-index pattern-index.yaml s3-practical-guide.md

# build reveal.js
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=text --glossary=glossary.yaml
mdslides build revealjs s3-practical-guide.yaml  tmp/ reveal.js/s3-practical-guide.html --template=templates/revealjs-template.html  --glossary=glossary.yaml  --glossary-items=8

# build wordpress output
mdslides compile s3-practical-guide.yaml src/ tmp/ --chapter-title=none --glossary=glossary.yaml
mdslides build wordpress s3-practical-guide.yaml tmp/ web-out/ --footer=templates/wordpress-footer.md  --glossary=glossary.yaml