#!/usr/bin/env python

import os
import sys

import jinja2
import yaml


if len(sys.argv) < 2:
    print('Usage:\n    $ %s <template-file-path> [project-paths-path-yml]\n' % sys.argv[0])
    sys.exit(1)


dci_template_file_path = sys.argv[1]
if not os.path.exists(dci_template_file_path):
    print("Template file '%s' does not exist." % dci_template_file_path)
    sys.exit(1)

default_project_paths = {'dci_cs_path'   : './dci-control-server',
                         'dciclient_path': './python-dcilient',
                         'dci_doc_path'  : './dci-doc',
                         'dci_ui_path'   : './dci-ui'}


if len(sys.argv) > 2:
    project_paths_path = sys.argv[2]
    if os.path.exists(project_paths_path):
        project_paths_content = open(project_paths_path, 'r').read()
        project_paths = yaml.load(project_paths_content)
        default_project_paths.update(project_paths)
    else:
        print("Project paths file'%s' does not exist." % project_paths_path)
        sys.exit(1)

template_content = open(dci_template_file_path).read()
template = jinja2.Template(template_content)
rendered_dci_template = template.render(**default_project_paths)

with open('./dci.jinja2.yml', 'w') as rendered_dci_template_file:
    rendered_dci_template_file.write(rendered_dci_template)

print('Rendered file to ./dci.jinja2.yml\n')

