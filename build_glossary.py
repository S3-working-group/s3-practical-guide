#!/usr/bin/env python

import yaml
from string import Template
from textwrap import dedent


def read_config(filename):
    stream = open(filename, "r")
    return yaml.load(stream)


def make_title(name):
    return name.title().replace('s3', 'S3')


DECKSET_TEMPLATE = "**%(name)s**: %(glossary)s"
HTML_TEMPLATE = "%(name)s\n: %(glossary)s"


def make_deckset_glossary(c):
    interate_elements(c, deckset_entry)


def make_html_glossary(c):
    interate_elements(c, html_entry)


def interate_elements(c, callback):
    for idx, item in enumerate(sorted(c['terms'].values(), key=lambda value: value['name'])):
        callback(item)


def deckset_entry(item):
    print DECKSET_TEMPLATE % item


def html_entry(item):
    print HTML_TEMPLATE % item


if __name__ == "__main__":
    c = read_config("glossary.yaml")
    make_deckset_glossary(c)
    make_html_glossary(c)
