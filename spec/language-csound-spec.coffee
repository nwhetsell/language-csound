LanguageCsound = require '../lib/language-csound'

describe 'language-csound', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-csound')

  describe 'Csound orchestra grammar', ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName('source.csound')

    it 'is defined', ->
      expect(grammar.scopeName).toBe 'source.csound'

    it 'tokenizes lines', ->
      lines = grammar.tokenizeLines '''
        nchnls = 1
        sr = 44100
      '''
      expect(lines[0][0]).toEqual value: 'nchnls', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[0][2]).toEqual value: '1', scopes: ['source.csound', 'constant.numeric.integer.decimal.csound']
      expect(lines[1][0]).toEqual value: 'sr', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[1][2]).toEqual value: '44100', scopes: ['source.csound', 'constant.numeric.integer.decimal.csound']

    it 'tokenizes header global variables', ->
      lines = grammar.tokenizeLines '''
        nchnls
        nchnls_i
        sr
        0dbfs
        kr
        ksmps
      '''
      expect(lines[0][0]).toEqual value: 'nchnls', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[1][0]).toEqual value: 'nchnls_i', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[2][0]).toEqual value: 'sr', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[3][0]).toEqual value: '0dbfs', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[4][0]).toEqual value: 'kr', scopes: ['source.csound', 'variable.other.readwrite.global.csound']
      expect(lines[5][0]).toEqual value: 'ksmps', scopes: ['source.csound', 'variable.other.readwrite.global.csound']

    it 'tokenizes user-defined opcodes', ->
      # The Csound orchestra grammar relies on the existence of an active text
      # editor to map user-defined opcodes to text buffers.
      waitsForPromise ->
        atom.workspace.open()
