# Sociocracy 3.0 - All Patterns Explained

This is a slide deck for teaching the patterns in Sociocracy 3.0. The deck is currently built in [Deckset](decksetapp.com), with plans to create a html-version in [reveal.js](http://lab.hakim.se/reveal-js/#/).

The deck is available for download as pdf or as an archive with individual pngs for each slide in the [releases section](https://github.com/bboc/s3-patterns/releases)

Translated versions will be available later this year.

## Build Process

The Markdown files for the individual patterns are grouped in directories per patterns group and built using a build script. Input format is Deckset (for now), i.e. slide separators are "---".

The image folder is symlinked to all subfolders, so images can easily be added without relative paths.

The build process requires [s3tools](https://github.com/S3-working-group/s3-tools) to compile the individual files into the Deckset file `slides.md`, which is then exported to the pdf and png versions. 

## Future Plans

Since Deckset is nice to hack together a quick presentation, but is a bit lacking when it comes to navigating larger presentations, and it's a Mac-Only app, we will move to a more open format in the future. 

There is already a generator for reveal.js, but as of now there's still issues with images, and a few other glitches. Maybe Multimarkdown and Beamer is also an option for the future.

[Reveal.js docs](https://github.com/hakimel/reveal.js/blob/master/README.md)

## Markdown Styleguide

Information in this section is preliminary, and needs further testing.

* Images always float right (because that works without clearing the float in reveal.js), and are set to height of 100%. Floating images go BEFORE the text, and are marked "right,fit"
* single images on slides: [inline,fit]
* Headline Level 1 is always the only content on the slide (apart from background images)
* Headline level 2  or more is increased by one for reveal.js


## License 

[![](http://creativecommons.org/images/deed/seal.png)](http://creativecommons.org/freeworks)

This slide deck is created by Bernhard Bockelbrink and James Priest, using illustrations from the [S3-Illustrations Repository](https://github.com/S3-working-group/s3-illustrations).

_Sociocracy 3.0 - All Patterns Explained_ is licensed to you under a **Creative Commons Free Culture License**. The exact license can be viewed [here](http://creativecommons.org/licenses/by-sa/4.0/).

Basically this license grants you

1. Freedom to use the work itself.
2. Freedom to use the information in the work for any purpose, even commercially.
3. Freedom to share copies of the work for any purpose, even commercially.
4. Freedom to make and share remixes and other derivatives for any purpose. 

You need to attribute the original creator of the materials, and all derivatives need to be shared under the same license. There's more on the topic of free culture on the [Creative Commons website.](http://creativecommons.org/freeworks)
