describe 'language-csound', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage 'language-csound'

  describe 'Csound Orchestra grammar', ->
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
      expect(tokens[0]).toEqual value: 'instr', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'keyword.function.csound']
      expect(tokens[1]).toEqual value: '/*', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[3]).toEqual value: '1', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'entity.name.function.csound']
      expect(tokens[4]).toEqual value: ',', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound']
      expect(tokens[5]).toEqual value: '/*', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[6]).toEqual value: '*/', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[7]).toEqual value: 'N_a_M_e_', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'entity.name.function.csound']
      expect(tokens[8]).toEqual value: ',', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound']
      expect(tokens[9]).toEqual value: '/*', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[10]).toEqual value: '*/', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[11]).toEqual value: '+', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound']
      expect(tokens[12]).toEqual value: 'Name', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'entity.name.function.csound']
      expect(tokens[13]).toEqual value: '//', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound', 'comment.line.csound', 'punctuation.definition.comment.line.csound']
      expect(tokens[14]).toEqual value: '', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.instrument-declaration.csound']

      tokens = lines[1]
      expect(tokens[0]).toEqual value: 'aLabel', scopes: ['source.csound', 'meta.instrument-block.csound', 'entity.name.label.csound']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.csound', 'meta.instrument-block.csound', 'entity.punctuation.label.csound']

      tokens = lines[2]
      expect(tokens[1]).toEqual value: 'i', scopes: ['source.csound', 'meta.instrument-block.csound', 'storage.type.csound']
      expect(tokens[2]).toEqual value: 'Duration', scopes: ['source.csound', 'meta.instrument-block.csound', 'meta.other.csound']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.csound', 'meta.instrument-block.csound']
      expect(tokens[4]).toEqual value: '=', scopes: ['source.csound', 'meta.instrument-block.csound', 'keyword.operator.csound']
      expect(tokens[5]).toEqual value: ' ', scopes: ['source.csound', 'meta.instrument-block.csound']
      expect(tokens[6]).toEqual value: 'p3', scopes: ['source.csound', 'meta.instrument-block.csound', 'support.variable.csound']

      tokens = lines[3]
      expect(tokens[0]).toEqual value: 'endin', scopes: ['source.csound', 'meta.instrument-block.csound', 'keyword.other.csound']

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
          expect(tokens[0]).toEqual value: 'opcode', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'keyword.function.csound']
          expect(tokens[1]).toEqual value: '/*', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
          expect(tokens[2]).toEqual value: '*/', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
          expect(tokens[3]).toEqual value: 'aUDO', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'entity.name.function.opcode.csound']
          expect(tokens[4]).toEqual value: ',', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound']
          expect(tokens[5]).toEqual value: '/*', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
          expect(tokens[6]).toEqual value: '*/', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
          expect(tokens[7]).toEqual value: '0', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'meta.opcode-argument-types.csound', 'storage.type.csound']
          expect(tokens[8]).toEqual value: ',', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'meta.opcode-argument-types.csound']
          expect(tokens[9]).toEqual value: '/*', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
          expect(tokens[10]).toEqual value: '*/', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
          expect(tokens[11]).toEqual value: '0', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'meta.opcode-argument-types.csound', 'storage.type.csound']
          expect(tokens[12]).toEqual value: '//', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound', 'meta.opcode-details.csound', 'meta.opcode-argument-types.csound', 'comment.line.csound', 'punctuation.definition.comment.line.csound']
          expect(tokens[13]).toEqual value: '', scopes: ['source.csound', 'meta.opcode-definition.csound', 'meta.opcode-declaration.csound']

          tokens = lines[1]
          expect(tokens[0]).toEqual value: 'aUDO', scopes: ['source.csound', 'meta.opcode-definition.csound', 'entity.name.function.opcode.csound']

          tokens = lines[2]
          expect(tokens[0]).toEqual value: 'endop', scopes: ['source.csound', 'meta.opcode-definition.csound', 'keyword.other.csound']

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
      lines = grammar.tokenizeLines preprocessorDirectives.join('\n')
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: preprocessorDirectives[i], scopes: ['source.csound', 'keyword.preprocessor.csound']

    it 'tokenizes includes', ->
      lines = grammar.tokenizeLines '#include/**/"file.udo"'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '#include', scopes: ['source.csound', 'keyword.include.preprocessor.csound']
      expect(tokens[1]).toEqual value: '/*', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[3]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.include.csound', 'punctuation.definition.string.begin.csound']
      expect(tokens[4]).toEqual value: 'file.udo', scopes: ['source.csound', 'string.quoted.include.csound']
      expect(tokens[5]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.include.csound', 'punctuation.definition.string.end.csound']

    it 'tokenizes macro definitions', ->
      lines = grammar.tokenizeLines '# \tdefine/**/MACRO(ARGUMENT)/**/#$ARGUMENT#'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '# \tdefine', scopes: ['source.csound', 'keyword.define.preprocessor.csound']
      expect(tokens[1]).toEqual value: '/*', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[3]).toEqual value: 'MACRO', scopes: ['source.csound', 'entity.name.function.preprocessor.csound']
      expect(tokens[4]).toEqual value: '(', scopes: ['source.csound']
      expect(tokens[5]).toEqual value: 'ARGUMENT', scopes: ['source.csound', 'variable.parameter.preprocessor.csound']
      expect(tokens[6]).toEqual value: ')', scopes: ['source.csound']
      expect(tokens[7]).toEqual value: '/*', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.begin.csound']
      expect(tokens[8]).toEqual value: '*/', scopes: ['source.csound', 'comment.block.csound', 'punctuation.definition.comment.end.csound']
      expect(tokens[9]).toEqual value: '#', scopes: ['source.csound', 'punctuation.definition.macro.begin.csound']
      expect(tokens[10]).toEqual value: '$ARGUMENT', scopes: ['source.csound', 'entity.name.function.preprocessor.csound']
      expect(tokens[11]).toEqual value: '#', scopes: ['source.csound', 'punctuation.definition.macro.end.csound']

    it 'tokenizes header global variables', ->
      headerGlobalVariables = [
        '0dbfs'
        'kr'
        'ksmps'
        'nchnls'
        'nchnls_i'
        'sr'
      ]
      lines = grammar.tokenizeLines headerGlobalVariables.join('\n')
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: headerGlobalVariables[i], scopes: ['source.csound', 'variable.other.readwrite.global.csound']

    it 'tokenizes quoted strings', ->
      lines = grammar.tokenizeLines '"characters$MACRO."'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.csound', 'punctuation.definition.string.begin.csound']
      expect(tokens[1]).toEqual value: 'characters', scopes: ['source.csound', 'string.quoted.csound']
      expect(tokens[2]).toEqual value: '$MACRO.', scopes: ['source.csound', 'string.quoted.csound', 'entity.name.function.preprocessor.csound']
      expect(tokens[3]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.csound', 'punctuation.definition.string.end.csound']

    it 'tokenizes escaped characters', ->
      escapedCharacters = [
        '%!'
        '%%'
        '%n'
        '%N'
        '%r'
        '%R'
        '%t'
        '%T'
        '\\\\'
        '\\a'
        '\\A'
        '\\b'
        '\\B'
        '\\n'
        '\\N'
        '\\r'
        '\\R'
        '\\t'
        '\\T'
        '\\"'
        '\\012'
        '\\345'
        '\\67'
      ]
      lines = grammar.tokenizeLines '"' + escapedCharacters.join('') + '"'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.csound', 'punctuation.definition.string.begin.csound']
      for i in [1...tokens.length - 1]
        expect(tokens[i]).toEqual value: escapedCharacters[i - 1], scopes: ['source.csound', 'string.quoted.csound', 'constant.character.escape.csound']
      expect(tokens[tokens.length - 1]).toEqual value: '"', scopes: ['source.csound', 'string.quoted.csound', 'punctuation.definition.string.end.csound']

    it 'tokenizes braced strings', ->
      lines = grammar.tokenizeLines '{{characters}}'
      tokens = lines[0]
      expect(tokens[0]).toEqual value: '{{', scopes: ['source.csound', 'string.braced.csound']
      expect(tokens[1]).toEqual value: 'characters', scopes: ['source.csound', 'string.braced.csound']
      expect(tokens[2]).toEqual value: '}}', scopes: ['source.csound', 'string.braced.csound']

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
        'then'
        'timout'
        'until'
        'while'
      ]
      lines = grammar.tokenizeLines keywords.join('\n')
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: keywords[i], scopes: ['source.csound', 'keyword.control.csound']

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
        'rigoto'
        'tigoto'
        ''
      ]
      # Putting a label after each string is enough to test the grammar, but
      # it is not always valid Csound syntax. In particular, loop_ge, loop_gt,
      # loop_le, and loop_lt all take four arguments, the last of which is a
      # label.
      lines = grammar.tokenizeLines keywordsAndOpcodes.join ' aLabel //\n'
      for i in [0...lines.length - 1]
        tokens = lines[i]
        expect(tokens[0]).toEqual value: keywordsAndOpcodes[i], scopes: ['source.csound', 'keyword.control.csound']
        expect(tokens[1]).toEqual value: ' ', scopes: ['source.csound']
        expect(tokens[2]).toEqual value: 'aLabel', scopes: ['source.csound', 'entity.name.label.csound']
        expect(tokens[3]).toEqual value: ' ', scopes: ['source.csound']
        expect(tokens[4]).toEqual value: '//', scopes: ['source.csound', 'comment.line.csound', 'punctuation.definition.comment.line.csound']
