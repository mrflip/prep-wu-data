#!/sw/bin/env python
import csv
import re
import yaml
from   pprint import pprint
import os

# from gnosis.xml.pickle import XML_Pickler
import gnosis.xml.pickle

def split_tags(taglist):
    return taglist.split()

def head_fields_unlazy(head):
    # where the short (lazy) name was used, coerce to the proper name,
    # discarding all others.
    fields_names = [('n','name'),('d','description'),('t','type'), ('u','units')]
    head['fields'] = [ dict([(l_name, (field.get(l_name) or field.get(s_name)))
                                 for (s_name, l_name) in  fields_names])
                           for field in head['fields']]


class Dataset(object):
    __slots__ = ('head', 'body')
    def __init__(self, head):
        self.head = head
        self.body = ()

    def dump_YAML(self):
        data = {'infochimp_head': self.head, 'infochimp_body': self.body}
        yamlstring = yaml.dump(data, default_flow_style=False, default_style=None, allow_unicode=True)
        yamlfile = open(self.head['name']+'.yml', "w")
        print >>yamlfile, yamlstring
        print yamlstring


    def grokfile(self, sourceinfo):
        # switch
        {'csv':    self.grokfile_csv,
         }[sourceinfo['format']](sourceinfo)

    def grokfile_csv(self, sourceinfo):
        csvLines = csv.reader(open(sourceinfo['infile'], "rb"))
        self.body = [line for line in csvLines]
            


# pull in initial schema
# schema_in_filename = re.sub(r'-parse.py', '-schema-in.yml', __file__)
schema_in_filename = "geonames-currency-shortnames-schema-in.yml"
schema_in = yaml.safe_load(open(schema_in_filename, "r"))

# grok schema
head_fields_unlazy(schema_in['head'])

dataset = Dataset(schema_in['head'])
dataset.grokfile(schema_in['sourceinfo'])

# pprint(dataset.body)
dataset.dump_YAML()
 
