describe 'language-csound', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage 'language-csound'

  describe 'Csound grammar', ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName 'source.csound'

    it 'is defined', ->
      expect(grammar.scopeName).toBe 'source.csound'

    it 'tokenizes instrument blocks', ->
      lines = grammar.tokenizeLines '''
        instr/**/1,/**/N_a_M_e_,/**/+Name//
        aLabel:
          iDuration = p3
        endin
      '''

      tokens = lines[0]
      expect(tokens.length).toBe 15
      expect(tokens[0]).toEqual value: 'instr', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'keyword.function.csound'
      ]
      expect(tokens[1]).toEqual value: '/*', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[2]).toEqual value: '*/', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[3]).toEqual value: '1', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'entity.name.function.csound'
      ]
      expect(tokens[4]).toEqual value: ',', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
      ]
      expect(tokens[5]).toEqual value: '/*', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[6]).toEqual value: '*/', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[7]).toEqual value: 'N_a_M_e_', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'entity.name.function.csound'
      ]
      expect(tokens[8]).toEqual value: ',', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
      ]
      expect(tokens[9]).toEqual value: '/*', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[10]).toEqual value: '*/', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[11]).toEqual value: '+', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
      ]
      expect(tokens[12]).toEqual value: 'Name', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'entity.name.function.csound'
      ]
      expect(tokens[13]).toEqual value: '//', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
        'comment.line.csound'
        'punctuation.definition.comment.line.csound'
      ]
      expect(tokens[14]).toEqual value: '', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.instrument-declaration.csound'
      ]

      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: 'aLabel', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'entity.name.label.csound'
      ]
      expect(tokens[1]).toEqual value: ':', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'entity.punctuation.label.csound'
      ]

      tokens = lines[2]
      expect(tokens.length).toBe 7
      expect(tokens[1]).toEqual value: 'i', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'storage.type.csound'
      ]
      expect(tokens[2]).toEqual value: 'Duration', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'meta.other.csound'
      ]
      expect(tokens[3]).toEqual value: ' ', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
      ]
      expect(tokens[4]).toEqual value: '=', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'keyword.operator.csound'
      ]
      expect(tokens[5]).toEqual value: ' ', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
      ]
      expect(tokens[6]).toEqual value: 'p3', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'support.variable.csound'
      ]

      tokens = lines[3]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: 'endin', scopes: [
        'source.csound'
        'meta.instrument-block.csound'
        'keyword.other.csound'
      ]

    it 'tokenizes user-defined opcodes', ->
      # The Csound Orchestra grammar relies on the existence of an active text
      # editor to tokenize user-defined opcodes.
      waitsForPromise ->
        atom.workspace.open().then (editor) ->
          lines = grammar.tokenizeLines '''
            opcode/**/aUDO,/**/0,/**/0//
            aUDO
            endop
          '''

          tokens = lines[0]
          expect(tokens.length).toBe 14
          expect(tokens[0]).toEqual value: 'opcode', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'keyword.function.csound'
          ]
          expect(tokens[1]).toEqual value: '/*', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'comment.block.csound'
            'punctuation.definition.comment.begin.csound'
          ]
          expect(tokens[2]).toEqual value: '*/', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'comment.block.csound'
            'punctuation.definition.comment.end.csound'
          ]
          expect(tokens[3]).toEqual value: 'aUDO', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'entity.name.function.opcode.csound'
          ]
          expect(tokens[4]).toEqual value: ',', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
          ]
          expect(tokens[5]).toEqual value: '/*', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'comment.block.csound'
            'punctuation.definition.comment.begin.csound'
          ]
          expect(tokens[6]).toEqual value: '*/', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'comment.block.csound'
            'punctuation.definition.comment.end.csound'
          ]
          expect(tokens[7]).toEqual value: '0', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'meta.opcode-type-signature.csound'
            'storage.type.csound'
          ]
          expect(tokens[8]).toEqual value: ',', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'meta.opcode-type-signature.csound'
          ]
          expect(tokens[9]).toEqual value: '/*', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'comment.block.csound'
            'punctuation.definition.comment.begin.csound'
          ]
          expect(tokens[10]).toEqual value: '*/', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'comment.block.csound'
            'punctuation.definition.comment.end.csound'
          ]
          expect(tokens[11]).toEqual value: '0', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'meta.opcode-type-signature.csound'
            'storage.type.csound'
          ]
          expect(tokens[12]).toEqual value: '//', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
            'meta.opcode-details.csound'
            'meta.opcode-type-signature.csound'
            'comment.line.csound'
            'punctuation.definition.comment.line.csound'
          ]
          expect(tokens[13]).toEqual value: '', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'meta.opcode-declaration.csound'
          ]

          tokens = lines[1]
          expect(tokens.length).toBe 1
          expect(tokens[0]).toEqual value: 'aUDO', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'entity.name.function.opcode.csound'
          ]

          tokens = lines[2]
          expect(tokens.length).toBe 1
          expect(tokens[0]).toEqual value: 'endop', scopes: [
            'source.csound'
            'meta.opcode-definition.csound'
            'keyword.other.csound'
          ]

    it 'tokenizes comments', ->
      lines = grammar.tokenizeLines '''
        /*
         * comment
         */
        ; comment
        // comment
      '''
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: '/*', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: ' * comment', scopes: [
        'source.csound'
        'comment.block.csound'
      ]
      tokens = lines[2]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: ' ', scopes: [
        'source.csound'
        'comment.block.csound'
      ]
      expect(tokens[1]).toEqual value: '*/', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      tokens = lines[3]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: ';', scopes: [
        'source.csound'
        'comment.line.csound'
        'punctuation.definition.comment.line.csound'
      ]
      expect(tokens[1]).toEqual value: ' comment', scopes: [
        'source.csound'
        'comment.line.csound'
      ]
      tokens = lines[4]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: '//', scopes: [
        'source.csound'
        'comment.line.csound'
        'punctuation.definition.comment.line.csound'
      ]
      expect(tokens[1]).toEqual value: ' comment', scopes: [
        'source.csound'
        'comment.line.csound'
      ]

    it 'tokenizes numbers', ->
      lines = grammar.tokenizeLines '''
        123
        0123456789
      '''
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: '123', scopes: [
        'source.csound'
        'constant.numeric.integer.decimal.csound'
      ]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: '0123456789', scopes: [
        'source.csound'
        'constant.numeric.integer.decimal.csound'
      ]

      lines = grammar.tokenizeLines '''
        0xabcdef0123456789
        0XABCDEF
      '''
      tokens = lines[0]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: '0x', scopes: [
        'source.csound'
        'storage.type.number.csound'
      ]
      expect(tokens[1]).toEqual value: 'abcdef0123456789', scopes: [
        'source.csound'
        'constant.numeric.integer.hexadecimal.csound'
      ]
      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: '0X', scopes: [
        'source.csound'
        'storage.type.number.csound'
      ]
      expect(tokens[1]).toEqual value: 'ABCDEF', scopes: [
        'source.csound'
        'constant.numeric.integer.hexadecimal.csound'
      ]

      floats = [
        '1e2'
        '3e+4'
        '5e-6'
        '7E8'
        '9E+0'
        '1E-2'
        '3.'
        '4.56'
        '.789'
      ]
      lines = grammar.tokenizeLines(floats.join '\n')
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: floats[i], scopes: [
          'source.csound'
          'constant.numeric.float.csound'
        ]

    it 'tokenizes quoted strings', ->
      tokens = (grammar.tokenizeLines '"characters$MACRO."')[0]
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: '"', scopes: [
        'source.csound'
        'string.quoted.csound'
        'punctuation.definition.string.begin.csound'
      ]
      expect(tokens[1]).toEqual value: 'characters', scopes: [
        'source.csound'
        'string.quoted.csound'
      ]
      expect(tokens[2]).toEqual value: '$MACRO.', scopes: [
        'source.csound'
        'string.quoted.csound'
        'entity.name.function.preprocessor.csound'
      ]
      expect(tokens[3]).toEqual value: '"', scopes: [
        'source.csound'
        'string.quoted.csound'
        'punctuation.definition.string.end.csound'
      ]

    it 'tokenizes braced strings', ->
      lines = grammar.tokenizeLines '''
        {{
        characters$MACRO.
        }}
      '''
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: '{{', scopes: [
        'source.csound'
        'string.braced.csound'
      ]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: 'characters$MACRO.', scopes: [
        'source.csound'
        'string.braced.csound'
      ]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: '}}', scopes: [
        'source.csound'
        'string.braced.csound'
      ]

    it 'tokenizes escape sequences', ->
      escapeSequences = [
        '\\\\'
        '\\a'
        '\\b'
        '\\n'
        '\\r'
        '\\t'
        '\\"'
        '\\012'
        '\\345'
        '\\67'
      ]
      tokens = (grammar.tokenizeLines "\"#{escapeSequences.join ''}\"")[0]
      for i in [1...tokens.length - 1]
        expect(tokens[i]).toEqual value: escapeSequences[i - 1], scopes: [
          'source.csound'
          'string.quoted.csound'
          'constant.character.escape.csound'
        ]
      tokens = (grammar.tokenizeLines "{{#{escapeSequences.join ''}}}")[0]
      for i in [1...tokens.length - 1]
        expect(tokens[i]).toEqual value: escapeSequences[i - 1], scopes: [
          'source.csound'
          'string.braced.csound'
          'constant.character.escape.csound'
        ]

    it 'tokenizes operators', ->
      operators = [
        '+'
        '-'
        '~', '¬'
        '!'
        '*'
        '/'
        '^'
        '%'
        '<<'
        '>>'
        '<'
        '>'
        '<='
        '>='
        '=='
        '!='
        '&'
        '#'
        '|'
        '&&'
        '||'
        '?', ':'
        '+='
        '-='
        '*='
        '/='
      ]
      lines = grammar.tokenizeLines "#{operators.join '\n'}"
      expect(lines.length).toBe operators.length
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: operators[i], scopes: [
          'source.csound'
          'keyword.operator.csound'
        ]

    it 'tokenizes global value identifiers', ->
      globalValueIdentifiers = [
        '0dbfs'
        'A4'
        'kr'
        'ksmps'
        'nchnls'
        'nchnls_i'
        'sr'
      ]
      lines = grammar.tokenizeLines(globalValueIdentifiers.join '\n')
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: globalValueIdentifiers[i], scopes: [
          'source.csound'
          'variable.other.readwrite.global.csound'
        ]

    it 'tokenizes keywords', ->
      keywords = [
        'do'
        'else'
        'elseif'
        'endif'
        'enduntil'
        'fi'
        'if'
        'ithen'
        'kthen'
        'od'
        'return'
        'rireturn'
        'then'
        'until'
        'while'
      ]
      lines = grammar.tokenizeLines(keywords.join '\n')
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: keywords[i], scopes: [
          'source.csound'
          'keyword.control.csound'
        ]

    it 'tokenizes string formatting opcodes', ->
      opcodes = [
        'printks'
        'prints'
      ]
      escapeSequences = [
        '%!'
        '%%'
        '%n'
        '%N'
        '%r'
        '%R'
        '%t'
        '%T'
        '\\A'
        '\\B'
        '\\N'
        '\\R'
        '\\T'
      ]
      for opcode in opcodes
        tokens = (grammar.tokenizeLines "#{opcode} \"#{escapeSequences.join ''}\"")[0]
        expect(tokens[0]).toEqual value: opcode, scopes: [
          'source.csound'
          'support.function.csound'
        ]
        expect(tokens[1]).toEqual value: ' ', scopes: [
          'source.csound'
        ]
        expect(tokens[2]).toEqual value: '"', scopes: [
          'source.csound'
          'string.quoted.csound'
          'punctuation.definition.string.begin.csound'
        ]
        for i in [3...tokens.length - 1]
          expect(tokens[i]).toEqual value: escapeSequences[i - 3], scopes: [
            'source.csound'
            'string.quoted.csound'
            'constant.character.escape.csound'
          ]
        expect(tokens[tokens.length - 1]).toEqual value: '"', scopes: [
          'source.csound'
          'string.quoted.csound'
          'punctuation.definition.string.end.csound'
        ]

    it 'tokenizes goto statements', ->
      keywordsAndOpcodes = [
        'cggoto'
        'cigoto'
        'cingoto'
        'ckgoto'
        'cngoto'
        'goto'
        'igoto'
        'kgoto'
        'loop_ge'
        'loop_gt'
        'loop_le'
        'loop_lt'
        'reinit'
        'rigoto'
        'tigoto'
        'timout'
        ''
      ]
      # Putting a label after each string is enough to test the grammar, but
      # it’s not always valid Csound syntax. In particular, loop_ge, loop_gt,
      # loop_le, and loop_lt all take four arguments, the last of which is a
      # label.
      lines = grammar.tokenizeLines(keywordsAndOpcodes.join ' aLabel //\n')
      for i in [0...lines.length - 1]
        tokens = lines[i]
        expect(tokens[0]).toEqual value: keywordsAndOpcodes[i], scopes: [
          'source.csound'
          'keyword.control.csound'
        ]
        expect(tokens[1]).toEqual value: ' ', scopes: [
          'source.csound'
        ]
        expect(tokens[2]).toEqual value: 'aLabel', scopes: [
          'source.csound'
          'entity.name.label.csound'
        ]
        expect(tokens[3]).toEqual value: ' ', scopes: [
          'source.csound'
        ]
        expect(tokens[4]).toEqual value: '//', scopes: [
          'source.csound'
          'comment.line.csound'
          'punctuation.definition.comment.line.csound'
        ]

    it 'tokenizes preprocessor directives', ->
      preprocessorDirectives = [
        '#else'
        '#end'
        '#endif'
        '#ifdef'
        '#ifndef'
        '#undef'
        '###'
        '@ \t0'
        '@@ \t0'
      ]
      lines = grammar.tokenizeLines(preprocessorDirectives.join '\n')
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: preprocessorDirectives[i], scopes: [
          'source.csound'
          'keyword.preprocessor.csound'
        ]

    it 'tokenizes includes', ->
      lines = grammar.tokenizeLines '#include/**/"file.udo"'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '#include', scopes: [
        'source.csound'
        'keyword.include.preprocessor.csound'
      ]
      expect(tokens[1]).toEqual value: '/*', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[2]).toEqual value: '*/', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[3]).toEqual value: '"', scopes: [
        'source.csound'
        'string.quoted.include.csound'
        'punctuation.definition.string.begin.csound'
      ]
      expect(tokens[4]).toEqual value: 'file.udo', scopes: [
        'source.csound'
        'string.quoted.include.csound'
      ]
      expect(tokens[5]).toEqual value: '"', scopes: [
        'source.csound'
        'string.quoted.include.csound'
        'punctuation.definition.string.end.csound'
      ]

    it 'tokenizes macro definitions', ->
      lines = grammar.tokenizeLines '# \tdefine/**/MACRO(ARGUMENT)/**/#$ARGUMENT#'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '# \tdefine', scopes: [
        'source.csound'
        'keyword.define.preprocessor.csound'
      ]
      expect(tokens[1]).toEqual value: '/*', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[2]).toEqual value: '*/', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[3]).toEqual value: 'MACRO', scopes: [
        'source.csound'
        'entity.name.function.preprocessor.csound'
      ]
      expect(tokens[4]).toEqual value: '(', scopes: [
        'source.csound'
      ]
      expect(tokens[5]).toEqual value: 'ARGUMENT', scopes: [
        'source.csound'
        'variable.parameter.preprocessor.csound'
      ]
      expect(tokens[6]).toEqual value: ')', scopes: [
        'source.csound'
      ]
      expect(tokens[7]).toEqual value: '/*', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.begin.csound'
      ]
      expect(tokens[8]).toEqual value: '*/', scopes: [
        'source.csound'
        'comment.block.csound'
        'punctuation.definition.comment.end.csound'
      ]
      expect(tokens[9]).toEqual value: '#', scopes: [
        'source.csound'
        'punctuation.definition.macro.begin.csound'
      ]
      expect(tokens[10]).toEqual value: '$ARGUMENT', scopes: [
        'source.csound'
        'entity.name.function.preprocessor.csound'
      ]
      expect(tokens[11]).toEqual value: '#', scopes: [
        'source.csound'
        'punctuation.definition.macro.end.csound'
      ]
