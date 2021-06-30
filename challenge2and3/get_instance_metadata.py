#!/usr/bin/env python
import requests
import json

def get_instance_metadata():
    baseurl = 'http://169.254.169.254/latest/meta-data/'
    metadata = {}
    traverse_data(baseurl, metadata)
    return metadata


def traverse_data(baseurl, metadata):
    req = requests.get(baseurl)
    if req.status_code == 404:
        return

    for line in req.text.split('\n'):
        if not line:
            continue

        updated_url = '{0}{1}'.format(baseurl, line)
        if line.endswith('/'):
            newsection = line.split('/')[-2]
            metadata[newsection] = {}
            traverse_data(updated_url, metadata[newsection])
        else:
            req = requests.get(updated_url)
            if req.status_code != 404:
                try:
                    metadata[line] = json.loads(req.text)
                except ValueError:
                    metadata[line] = req.text
            else:
                metadata[line] = None

if __name__ == "__main__":
    print(json.dumps(get_instance_metadata()))