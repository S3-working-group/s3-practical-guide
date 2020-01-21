# Formats and Translations


## Slide Deck Formats

Currently the book is no longer published as a slide deck. In the future, a companion slide deck to the book might become available, so here's the documentation compiled for these formats

Downloads were available as PDF or PNG slides exported from [Deckset](decksetapp.com), and as a html-version in [reveal.js](http://lab.hakim.se/reveal-js/#/) .

Deckset is nice to quickly hack together a beautiful presentation, but is a bit lacking when it comes to navigating larger presentations, and it's only available as a macOS app. Building the Hebrew version I discovered the hard way it does not support RTL languages., and did not find a way to automate pdf export, so with a growing number of languages Deckset is becoming increasingly painful. 

This is why I was looking at more open formats, and developed a generator for reveal.js, which generally worked well enough.

[Reveal.js docs](https://github.com/hakimel/reveal.js/blob/master/README.md)

### Markdown for Slide Decks

The Markdown files for the individual patterns are grouped in directories per patterns group and built using a build script. Input format is Deckset 1 (for now), i.e. slide separators are "---". This will hopefully change in the future.

* Images always float right (because that works without clearing the float in reveal.js), and are set to height of 100%. Floating images go BEFORE the text, and are marked "right,fit"
* single images on slides: [inline,fit]
* Headline Level 1 is always the only content on the slide (apart from background images)
* Headline level 2  or more is increased by one for reveal.js
* within each pattern, the pattern title is headline level 2, all slides in patterns with a dedicated title need to use headline level 3, so it does not show up in the TOC on the website

### Updating reveal.js

Download zip from the [official repo](https://github.com/hakimel/reveal.js) and copy files over to `docs/reveal.js`. Diff `templates/revealjs-template.html` with `demo.html` to see if there are some changes to the basic html structure.

Keep (or adapt) `custom-styles.css` and `custom-theme.css` (derived from `css/theme/white.css`.

