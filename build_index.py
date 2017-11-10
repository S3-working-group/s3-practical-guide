#!/usr/bin/env python

import yaml
from string import Template
from textwrap import dedent


def read_config(filename):
    stream = open(filename, "r")
    return yaml.load(stream)


def make_title(name):
    return name.title().replace('s3', 'S3')


def output_groups(config):
    P = "- %s"
    G = "\n### %s\n"

    for group in config["chapter_order"]:
        print G % make_title(group)
        for pattern in config["chapters"][group]:
            print P % make_title(pattern)


def index_by_group(config):
    PNAME = "P %s.%s: %s"
    GNAME = "%s: %s"

    TABLE = Template(dedent("""
        # Pattern Index $cont

        $left_header | $right_header
        --- | ---
        $left_content | $right_content
        """))

    groups = []
    patterns = {}
    for gid, group in enumerate(config["chapter_order"], 1):
        g = GNAME % (gid, make_title(group))
        groups.append(g)
        patterns[g] = [PNAME % (gid, pid, make_title(pattern))
                       for pid, pattern in enumerate(config["chapters"][group], 1)]
    cont = ''
    for page in range(0, len(groups), 2):
        lhead = groups[page]
        lcon = make_cell(patterns[lhead])
        try:
            rhead = groups[page + 1]
            rcon = make_cell(patterns[rhead])
        except IndexError:
            # odd number of groups
            rhead = '.'
            rcon = '<br/>'

        print "\n\n---\n\n"
        print TABLE.substitute(cont=cont,
                               left_header=lhead,
                               left_content=lcon,
                               right_header=rhead,
                               right_content=rcon)
        cont = "(cont.)"


def make_cell(items):
    return '<br\>'.join(items)


def alphabetical_index(config, per_page=20):
    """Create an alphabetical index of patterns as a deckset table."""

    INDEX_ENTRY = Template("$name - $gid.$pid")
    INDEX_TABLE = Template(dedent("""
        Patterns $cont | Patterns (cont.)
        --- | ---
        $left_content | $right_content
        """))

    patterns = []
    for gid, group in enumerate(config["chapter_order"], 1):
        patterns.extend([INDEX_ENTRY.substitute(name=make_title(pattern),
                                                gid=gid, pid=pid)
                        for pid, pattern in enumerate(config["chapters"][group], 1)])

    patterns.sort()
    cont = ''

    def cut_patterns(patterns):
        return patterns[:per_page], patterns[per_page:]

    for idx in range(0, len(patterns), per_page * 2):
        lgroup, patterns = cut_patterns(patterns)
        if patterns:
            rgroup, patterns = cut_patterns(patterns)
        else:
            rgroup = []

        print "\n\n---\n\n"
        print INDEX_TABLE.substitute(cont=cont,
                                     left_content=make_cell(lgroup),
                                     right_content=make_cell(rgroup))
        cont = "(cont.)"


if __name__ == "__main__":
    c = read_config("s3-practical-guide.yaml")
    # index_by_group(c)
    # output_groups(c)
    alphabetical_index(c)
