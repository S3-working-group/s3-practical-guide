# Sociocracy 3.0 - A Practical Guide

This is a slide deck for teaching the patterns in Sociocracy 3.0. The deck is currently built in [Deckset](decksetapp.com), and a html-version in [reveal.js](http://lab.hakim.se/reveal-js/#/).

The deck is available for download as pdf or as an archive with individual pngs from [sociocracy30.org/guide](http://sociocracy30.org/guide)) or as [online presentation](http://sociocracy30.org/slides/s3-practical-guide.html). 

Translated versions will be available later this year.

## Build Process

The Markdown files for the individual patterns are grouped in directories per patterns group and built using a build script. Input format is Deckset (for now), i.e. slide separators are "---".

The image folder is symlinked to all subfolders, so images can easily be added without relative paths.

The build process requires [s3tools](https://github.com/S3-working-group/s3-tools) to compile the individual files into the Deckset file `slides.md`, which is then exported to the pdf and png versions. 

## Future Plans

Since Deckset is nice to hack together a quick presentation, but is a bit lacking when it comes to navigating larger presentations, and it's a Mac-Only app, we will move to a more open format in the future. 

There is already a generator for reveal.js, but as of now there might still a few small glitches in the CSS. Ping me if you find one. 

[Reveal.js docs](https://github.com/hakimel/reveal.js/blob/master/README.md)

## Markdown Styleguide

Information in this section is preliminary, and needs further testing.

* Images always float right (because that works without clearing the float in reveal.js), and are set to height of 100%. Floating images go BEFORE the text, and are marked "right,fit"
* single images on slides: [inline,fit]
* Headline Level 1 is always the only content on the slide (apart from background images)
* Headline level 2  or more is increased by one for reveal.js
* within each pattern, the pattern title is headline level 2, all slides in patterns with a dedicated title need to use headline level 3, so it does not show up in the TOC on the website

## Updating reveal.js

Download zip from the [official repo](https://github.com/hakimel/reveal.js) and copy files over to `reveal.js`. Diff `templates/revealjs-template.html` with `demo.html` to see if there are some changes to the basic html structure.

Keep `custom-styles.css` and `custom-theme.css` (derived from `css/theme/white.css`.

## Translations

Slides are translated in a [dedicated crowdin project](https://crowdin.com/project/sociocracy-30). The repository contains `crowdin.yaml` for use with the [crowdin CLI](https://support.crowdin.com/cli-tool/). 

Uploading sources is handled through this command (remove `--dryrun` to run):

`crowdin --identity ~/crowdin-s3-patterns.yaml --dryrun upload sources`

We can create branches (e.g. to preserve old translations) but at the moment we don't need them:

`crowdin --identity ~/crowdin-s3-patterns.yaml --dryrun upload sources -b {branch name} --dryrun`

The config file can be checked using 
`crowdin --identity ~/crowdin-s3-patterns.yaml lint`

 These commands assume [crowdin credentials](https://support.crowdin.com/configuration-file/#cli-2) in `~/crowdin-s3-patterns.yaml`


## License 

[![](http://creativecommons.org/images/deed/seal.png)](http://creativecommons.org/freeworks)

This slide deck is created by Bernhard Bockelbrink and James Priest, using illustrations from the [S3-Illustrations Repository](https://github.com/S3-working-group/s3-illustrations) and [reveal.js](https://github.com/hakimel/reveal.js) by Hakim El Hattab.


_Sociocracy 3.0 - All Patterns Explained_ is licensed to you under a **Creative Commons Free Culture License**. The exact license can be viewed [here](http://creativecommons.org/licenses/by-sa/4.0/).

Basically this license grants you

1. Freedom to use the work itself.
2. Freedom to use the information in the work for any purpose, even commercially.
3. Freedom to share copies of the work for any purpose, even commercially.
4. Freedom to make and share remixes and other derivatives for any purpose. 

You need to attribute the original creator of the materials, and all derivatives need to be shared under the same license. There's more on the topic of free culture on the [Creative Commons website.](http://creativecommons.org/freeworks)

