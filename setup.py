# -*- coding: utf-8 -*-

import os

from setuptools import setup

here = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(here, ".version")) as fp:
    CLEVERCSV_VERSION = fp.read().strip()

REQUIRED = [f"clevercsv[precommit]=={CLEVERCSV_VERSION}"]

setup(
    name="clevercsv_pre_commit_dummy_package",
    version="0.0.0",
    install_requires=REQUIRED,
)
