#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Build pattern index in deckset format from yaml file with pattern database.
"""
import argparse
import codecs
import yaml
from string import Template
from textwrap import dedent


def read_config(filename):
    stream = open(filename, "r")
    return yaml.load(stream)


def make_title(name):
    return name.title().replace('s3', 'S3')


def make_cell(items):
    return '<br\>'.join(items)


def alphabetical_index(pattern_data, target, per_page=20):
    """Create an alphabetical index of patterns as a deckset table."""

    INDEX_ENTRY = Template("$name - $gid.$pid")
    INDEX_TABLE = Template(dedent("""
        Patterns $cont | Patterns (cont.)
        --- | ---
        $left_content | $right_content
        """))

    # sorting raw pattern data by name makes order independent of display format!
    pattern_data = sorted(pattern_data, key=lambda x: x['name'].lower())
    patterns = [INDEX_ENTRY.substitute(p) for p in pattern_data]

    cont = ''

    def cut_patterns(patterns):
        return patterns[:per_page], patterns[per_page:]

    for idx in range(0, len(patterns), per_page * 2):
        lgroup, patterns = cut_patterns(patterns)
        if patterns:
            rgroup, patterns = cut_patterns(patterns)
        else:
            rgroup = []

        if cont:
            target.write("\n\n---\n\n")
        target.write(INDEX_TABLE.substitute(cont=cont,
                                            left_content=make_cell(lgroup),
                                            right_content=make_cell(rgroup)))
        cont = "(cont.)"


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument('target')
    parser.add_argument('index_db')
    args = parser.parse_args()

    c = read_config(args.index_db)
    # c = read_config("pattern-index.yaml")
    with codecs.open(args.target, 'a', 'utf-8') as target:
        alphabetical_index(c['patterns'], target)
