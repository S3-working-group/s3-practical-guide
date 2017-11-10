#!/usr/bin/env python

"""
Build pattern index in deckset format from yaml file with pattern database.
"""
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


def alphabetical_index(pattern_data, per_page=20):
    """Create an alphabetical index of patterns as a deckset table."""

    INDEX_ENTRY = Template("$name - $gid.$pid")
    INDEX_TABLE = Template(dedent("""
        Patterns $cont | Patterns (cont.)
        --- | ---
        $left_content | $right_content
        """))

    # sorting raw pattern data by name makes order independent of display format!
    pattern_data = sorted(pattern_data, key=lambda x: x['name'])
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
        	print "\n\n---\n\n"
        print INDEX_TABLE.substitute(cont=cont,
                                     left_content=make_cell(lgroup),
                                     right_content=make_cell(rgroup))
        cont = "(cont.)"


if __name__ == "__main__":
    c = read_config("pattern-index.yaml")
    alphabetical_index(c['patterns'])
