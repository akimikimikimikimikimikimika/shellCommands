#! /usr/bin/env python3
# -*- coding: utf-8 -*-

from lib import CM,data
from analyze import argAnalyze
from execute import execute
from docs import help,version

d=data()

argAnalyze(d)

if d.mode==CM.main:    execute(d)
if d.mode==CM.help:    help()
if d.mode==CM.version: version()