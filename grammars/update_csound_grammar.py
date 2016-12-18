# -*- coding: utf-8 -*-

import re
from _csound_builtins import OPCODES, DEPRECATED_OPCODES
from regexopt import regex_opt

with open('csound.cson', 'r') as file:
    grammar = file.read()

pattern = r"""
      },{ # Update this pattern using update_csound_grammar\.py\.
        match: [^\n]+
        """
replacement = ("""
      },{ # Update this pattern using update_csound_grammar.py.
        match: '(?:""" +
    regex_opt(OPCODES, r'\\\\b', r'\\\\b').replace('\\_', '_') + '|' +
    regex_opt(DEPRECATED_OPCODES, r'\\\\b', r'\\\\b').replace('\\_', '_') +
    """)(?:(\\\\\\:)([A-Za-z]))?'
        """)

with open('csound.cson', 'w') as file:
    file.write(re.sub(pattern, replacement, grammar))
