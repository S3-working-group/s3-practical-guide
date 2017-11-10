#!/usr/bin/env python

"""
Build a yaml file with all patterns, and their IDs.
"""

import yaml
import codecs


def make_title(name):
    return name.title().replace('s3', 'S3')


if __name__ == "__main__":

    with open("s3-practical-guide.yaml", "r") as source:
        config = yaml.load(source)

    patterns = []
    for gid, group in enumerate(config["chapter_order"], 1):
        for pid, pattern in enumerate(config["chapters"][group], 1):
            patterns.append(dict(name=make_title(pattern), gid=gid, pid=pid))

    with codecs.open('pattern-index.yaml', 'w', 'utf-8') as target:
        yaml.dump(dict(patterns=sorted(patterns, key=lambda x: x['name'])), target, default_flow_style=False)
