# -*- coding: utf-8 -*-

import re
from _csound_builtins import OPCODES
from regexopt import regex_opt

pattern = r"""
      {
        name: 'support\.function\.csound'
        match: [^\n]+
      }"""
replacement = """
      {
        name: 'support.function.csound'
        match: '""" + regex_opt(OPCODES, r'\\\\b', r'\\\\b').replace('\\_', '_') + """'
      }"""
with open('csound.cson', 'r') as file:
    grammar = file.read()
with open('csound.cson', 'w') as file:
    file.write(re.sub(pattern, replacement, grammar))
