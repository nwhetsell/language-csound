# -*- coding: utf-8 -*-

import re
from _csound_builtins import OPCODES, DEPRECATED_OPCODES
from regexopt import regex_opt

with open('csound.cson', 'r') as file:
    grammar = file.read()

for tup in [('opcode', OPCODES), ('deprecated opcode', DEPRECATED_OPCODES)]:
    pattern = r"""
      { # This """ + tup[0] + r""" pattern should be updated using update_csound_grammar\.py\.
        match: [^\n]+
        """
    replacement = """
      { # This """ + tup[0] + """ pattern should be updated using update_csound_grammar.py.
        match: '""" + regex_opt(tup[1], r'\\\\b', r'\\\\b').replace('\\_', '_') + """(?:(\\\\\\:)([A-Za-z]))?'
        """
    grammar = re.sub(pattern, replacement, grammar)

with open('csound.cson', 'w') as file:
    file.write(grammar)
