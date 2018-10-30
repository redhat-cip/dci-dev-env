#!/usr/bin/env python
import os
from urllib.request import urlopen, urlretrieve
from lxml import etree
import gzip
import shutil
import argparse
import sys


def download_filelists(repo):
    url = repo["url"]
    repomd_url = "%srepodata/repomd.xml" % url
    print("download %s" % repomd_url)
    repomd_xml = urlopen(repomd_url)
    tree = etree.parse(repomd_xml)

    filelists_base_path = tree.xpath('//*[@type="filelists"]/*/@href')[0]
    filelists_path = "%s%s" % (url, filelists_base_path)

    filelists_tar, headers = urlretrieve(filelists_path)

    with gzip.open(filelists_tar, "rb") as f_in:
        with open(repo["tmp_file"], "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)


def remove_filelists(repo):
    filelists_path = repo["tmp_file"]
    print("remove %s" % filelists_path)
    os.remove(filelists_path)


def get_all_packages_name_and_version(filename):
    print("parse %s to get all packages name and version" % filename)
    packages = {}
    for event, element in etree.iterparse(filename, tag="{*}package"):
        name = element.attrib["name"]
        version = element.xpath(".//@ver")[0]
        packages[name] = version
        element.clear()
    return packages


def get_package_that_matches(packages, requirement):
    lower_requirement = requirement.lower()
    for package in packages.keys():
        names = [
            lower_requirement,
            "python-%s" % lower_requirement,
            "python2-%s" % lower_requirement,
            lower_requirement.replace("py", "", 1),
            lower_requirement.replace("py", "python-", 1),
            lower_requirement.replace("python-", "python2-", 1),
        ]
        for name in names:
            if name == package.lower():
                return package
    return None


def find_in(packages, requirements, info, buffer):
    remaining_requirements = []
    for requirement in requirements:
        package = get_package_that_matches(packages, requirement)
        if package:
            print("find %s in parsed packages" % requirement)
            buffer.append("%s==%s  # %s" % (requirement, packages[package], package))
        else:
            remaining_requirements.append(requirement)
    return buffer, remaining_requirements


def get_list_requirements(requirements_txt_filepath):
    buffer = []
    requirements = []
    with open(requirements_txt_filepath) as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith("#") or "# ignore" in line:
                buffer.append(line)
                continue
            line = line.split("=")[0]
            line = line.split("<")[0]
            line = line.split(">")[0]
            line = line.split("#")[0]
            requirements.append(line)
    return buffer, requirements


if len(sys.argv) < 2:
    print("Usage: %s <requirements.txt_path>" % sys.argv[0])
    print("example: %s dci-control-server/requirements.txt" % sys.argv[0])
    exit(1)


repos = [
    {
        "url": "http://mirror.centos.org/centos/7/os/x86_64/",
        "tmp_file": "/tmp/filelists.xml",
    },
    {
        "url": "http://mirror.centos.org/centos/7/extras/x86_64/",
        "tmp_file": "/tmp/filelists-extra.xml",
    },
    {
        "url": "https://packages.distributed-ci.io/repos/current/el/7/x86_64/",
        "tmp_file": "/tmp/filelists-dci.xml",
    },
    {
        "url": "https://packages.distributed-ci.io/repos/extras/el/7/x86_64/",
        "tmp_file": "/tmp/filelists-dci-extra.xml",
    },
    {
        "url": "https://dl.fedoraproject.org/pub/epel/6/x86_64/",
        "tmp_file": "/tmp/filelists-epel.xml",
    },
    {
        "url": "http://mirror.centos.org/centos/7/cloud/x86_64/openstack-pike/",
        "tmp_file": "/tmp/filelists-pike.xml",
    },
]

for repo in repos:
    download_filelists(repo)


for requirements_txt_filepath in sys.argv[1:]:
    print("Fix version in %s file" % requirements_txt_filepath)
    buffer, requirements = get_list_requirements(requirements_txt_filepath)
    for repo in repos:
        buffer, requirements = find_in(
            get_all_packages_name_and_version(repo["tmp_file"]),
            requirements,
            repo["url"],
            buffer,
        )

    if len(requirements):
        for r in requirements:
            buffer.insert(0, "%s  # ignore: /!\ Cannot find %s on repositories" % (r, r))

    with open(requirements_txt_filepath, "w") as f:
        for line in buffer:
            f.write("%s\n" % line)

for repo in repos:
    remove_filelists(repo)
