#!/usr/bin/env python

import os
import yaml
from string import Template


def read_config(filename):
    stream = open(filename, "r")
    return yaml.load(stream)


def make_title(name):
    return name.title().replace('s3', 'S3')


PNAME = "P %s.%s: %s"
GNAME = "%s: %s"

TABLE = Template("""
# Pattern Index $cont

$left_header | $right_header
 --- | ---
 $left_content | $right_content
 """)


template = "%(head_left)s"

if __name__ == "__main__":
    c = read_config("s3-all-patterns-explained.yaml")

    groups = []
    patterns = {}
    for gid, group in enumerate(c["chapter_order"], 1):
        g = GNAME % (gid, make_title(group))
        groups.append(g)
        patterns[g] = [PNAME % (gid, pid, make_title(pattern))
                       for pid, pattern in enumerate(c["chapters"][group], 1)]
    cont = ''
    for page in range(0, len(groups), 2):
        lhead = groups[page]
        lcon = '<br/>'.join(patterns[lhead])
        try:
            rhead = groups[page + 1]
            rcon = '<br/>'.join(patterns[rhead])
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
