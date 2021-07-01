#!/usr/bin/env python
import requests
import json
import sys


def get_instance_metadata(key):
    baseurl = 'http://169.254.169.254/latest/meta-data/'
    metadata = {}
    traverse_data(baseurl, metadata, key)
    return metadata


def traverse_data(baseurl, metadata, key):
    req = requests.get(baseurl)
    if req.status_code == 404:
        return

    for line in req.text.split('\n'):
        if not line:
            continue

        updated_url = '{0}{1}'.format(baseurl, line)
        if line.endswith('/'):
            newsection = line.split('/')[-2]
            if key is None:
                metadata[newsection] = {}
                traverse_data(updated_url, metadata[newsection], key)
            else:
                traverse_data(updated_url, metadata, key)
        else:
            req = requests.get(updated_url)
            if req.status_code != 404:
                if key is not None:
                    if key==line:
                        metadata[line] = req.text
                        break
                else:
                    try:
                        metadata[line] = json.loads(req.text)
                    except ValueError:
                        metadata[line] = req.text
            else:
                metadata[line] = None

if __name__ == "__main__":
    arguments = sys.argv
    arglength = len(arguments)
    key = None
    if arglength > 1:
        key = arguments[1]
    print(json.dumps(get_instance_metadata(key)))