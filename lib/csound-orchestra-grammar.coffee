{CompositeDisposable} = require 'atom'
{Grammar} = require 'first-mate'
# The first-mate module does not export the Pattern class.
path = require 'path'
Pattern = require path.join atom.config.resourcePath, 'node_modules', 'first-mate', 'lib', 'pattern.js'
CSON = require 'season'

class CsoundOrchestraGrammarPattern extends Pattern
  @opcodes = (completion.opcode for completion in CSON.readFileSync(path.resolve __dirname, '..', 'resources', 'opcode-completions.json').completions)

  setTagAtIndexToScope: (tags, index, scope) ->
    tags[index] = @registry.startIdForScope scope
    tags[index + 2] = @registry.endIdForScope scope

  handleMatch: (stack, line, captureIndicesArray, rule, endPatternMatch) ->
    tags = super

    userDefinedOpcodes = @grammar.userDefinedOpcodesForTextEditor atom.workspace.getActiveTextEditor()

    # Handle a Csound name as a parameter field, built-in opcode, user-defined
    # opcode, or variable with a storage-type prefix.
    newTags = tags.slice 0
    captureIndicesArrayIndex = captureIndicesArray.length
    for tag, index in tags by -1
      # Odd negative numbers are begin-scope tags.
      if (tag % 2) is -1
        captureIndicesArrayIndex--
        switch @registry.scopeForId tag
          when 'entity.name.function.opcode.csound'
            # Add names of user-defined opcodes to the opcode dictionary so they
            # can be scoped as function names.
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            userDefinedOpcodes.push line.substring captureIndices.start, captureIndices.end
          when 'meta.other.csound'
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            substring = line.substring captureIndices.start, captureIndices.end
            if /^p\d+$/.test substring
               # The substring is a parameter field.
              @setTagAtIndexToScope newTags, index, 'support.variable.csound'
            else if substring in CsoundOrchestraGrammarPattern.opcodes
               # The substring is a built-in opcode.
              @setTagAtIndexToScope newTags, index, 'support.function.csound'
            else if substring in userDefinedOpcodes
               # The substring is a user-defined opcode.
              @setTagAtIndexToScope newTags, index, 'entity.name.function.opcode.csound'
            else
              result = /^g?[aikpSw]/.exec substring
              if result
                # The substring begins with a type identifier.
                length = result[0].length
                newTags[index + 1] -= length
                scope = 'storage.type.csound'
                newTags.splice index, 0, @registry.startIdForScope(scope), length, @registry.endIdForScope(scope)

    newTags

module.exports =
class CsoundOrchestraGrammar extends Grammar
  constructor: (registry) ->
    options =
      scopeName: 'source.csound'
      fileTypes: ['orc']
      maxTokensPerLine: atom.grammars.maxTokensPerLine
      name: 'Csound Orchestra'
      patterns: [
        {
          include: '#commentsAndMacroCalls'
        }
        {
          name: 'meta.instrument-block.csound'
          begin: '\\b(?=instr\\b)'
          end: '\\bendin\\b'
          endCaptures:
            0:
              name: 'keyword.other.csound'
          patterns: [
            {
              name: 'meta.instrument-declaration.csound'
              begin: 'instr'
              beginCaptures:
                0:
                  name: 'keyword.function.csound'
              end: '\\n'
              patterns: [
                {
                  name: 'entity.name.function.csound'
                  match: '\\d+|\\+?[A-Z_a-z]\\w*'
                }
                {
                  include: '#commentsAndMacroCalls'
                }
              ]
            }
            {
              include: '#commentsAndMacroCalls'
            }
            {
              include: '#labels'
            }
            {
              include: '#partialExpressions'
            }
          ]
        }
        {
          name: 'meta.opcode-definition.csound'
          begin: '\\b(?=opcode\\b)'
          end: '\\bendop\\b'
          endCaptures:
            0:
              name: 'keyword.other.csound'
          patterns: [
            {
              name: 'meta.opcode-declaration.csound'
              begin: 'opcode'
              beginCaptures:
                0:
                  name: 'keyword.function.csound'
              end: '\\n'
              patterns: [
                {
                  name: 'meta.opcode-details.csound'
                  begin: '[A-Z_a-z]\\w*\\b'
                  beginCaptures:
                    0:
                      name: 'entity.name.function.opcode.csound'
                  end: '(?=\\n)'
                  patterns: [
                    {
                      name: 'meta.opcode-argument-types.csound'
                      begin: '\\b(?:0|[afijkKoOpPStV\\[\\]]+)\\b'
                      beginCaptures:
                        0:
                          name: 'storage.type.csound'
                      end: ',|(?=\\n)'
                      patterns: [
                        {
                          include: '#commentsAndMacroCalls'
                        }
                      ]
                    }
                    {
                      include: '#commentsAndMacroCalls'
                    }
                  ]
                }
                {
                  include: '#commentsAndMacroCalls'
                }
              ]
            }
            {
              include: '#commentsAndMacroCalls'
            }
            {
              include: '#labels'
            }
            {
              include: '#partialExpressions'
            }
          ]
        }
        {
          include: '#labels'
        }
        {
          include: '#partialExpressions'
        }
      ]
      repository:
        comments:
          # This must be kept synchronized with both the Csound Document and
          # Csound Score grammars.
          patterns: [
            {
              name: 'comment.block.csound'
              begin: '/\\*'
              beginCaptures:
                0:
                  name: 'punctuation.definition.comment.begin.csound'
              end: '\\*/'
              endCaptures:
                0:
                  name: 'punctuation.definition.comment.end.csound'
            }
            {
              name: 'comment.line.csound'
              begin: '//|;'
              beginCaptures:
                0:
                  name: 'punctuation.definition.comment.line.csound'
              end: '(?=\\n)'
            }
          ]
        commentsAndMacroCalls:
          patterns: [
            {
              include: '#comments'
            }
            {
              include: '#macroCalls'
            }
          ]
        labels:
          patterns: [
            match: '\\b(\\w+)(:)'
            captures:
              1:
                name: 'entity.name.label.csound'
              2:
                name: 'entity.punctuation.label.csound'
          ]
        macroCalls:
          # This must be kept synchronized with the Csound Score grammar.
          patterns: [
            {
              name: 'entity.name.function.preprocessor.csound'
              match: '\\$\\w+(?:\\.|\\b)'
            }
          ]
        partialExpressions:
          patterns: [
            { # These must be kept synchronized with the Csound Score grammar.
              name: 'keyword.preprocessor.csound'
              match: '\\#(?:(?:e(?:nd(?:if)?|lse)|i(?:fn?def|nclude)|undef)\\b|\\#\\#)|@+[ \\t]*\\d*'
            }
            { # These must be kept synchronized with the Csound Score grammar.
              begin: '\\#[ \\t]*define\\b'
              beginCaptures:
                0:
                  name: 'keyword.define.preprocessor.csound'
              end: '\\#'
              endCaptures:
                0:
                  name: 'meta.macro-definition.begin.csound'
              patterns: [
                {
                  begin: '\\w+'
                  beginCaptures:
                    0:
                      name: 'entity.name.function.preprocessor.csound'
                  end: '(?=\\#)'
                  patterns: [
                    {
                      begin: '\\('
                      end: '\\)'
                      patterns: [
                        name: 'entity.name.function.preprocessor.csound'
                        match: '\\w+(?:\\.|\\b)'
                      ]
                    }
                  ]
                }
              ]
            }
            {
              name: 'variable.other.readwrite.global.csound'
              match: '\\b(?:0dbfs|k(?:r|smps)|nchnls(?:_i)?|sr)\\b'
            }
            { # These must be kept synchronized with the Csound Score grammar.
              name: 'constant.numeric.float.csound'
              match: '(?:\\d+e[+-]?\\d+)|(?:\\d+\\.\\d*|\\d*\\.\\d+)(?:e[+-]?\\d+)?'
            }
            { # These must be kept synchronized with the Csound Score grammar.
              name: 'constant.numeric.integer.hexadecimal.csound'
              match: '0[Xx][a-fA-F0-9]+'
            }
            { # These must be kept synchronized with the Csound Score grammar.
              name: 'constant.numeric.integer.decimal.csound'
              match: '\\d+'
            }
            {
              name: 'string.quoted.csound'
              begin: '"'
              beginCaptures:
                0:
                  name: 'punctuation.definition.string.begin.csound'
              end: '"'
              endCaptures:
                0:
                  name: 'punctuation.definition.string.end.csound'
              patterns: [
                {
                  include: '#macroCalls'
                }
                {
                  name: 'constant.character.escape.csound'
                  # From
                  # https://github.com/csound/csound/blob/develop/Opcodes/fout.c#L1405
                  match: '%\\d*(\\.\\d+)?[cdhilouxX]'
                }
                {
                  name: 'constant.character.escape.csound'
                  match: '%[!%nNrRtT]|[~^]|\\\\(?:\\\\|[aAbBnNrRtT"]|[0-7]{1,3})'
                }
                {
                  name: 'invalid.illegal.unknown-escape.csound'
                  match: '\\\\.'
                }
              ]
            }
            {
              name: 'string.braced.csound'
              begin: '\\{\\{'
              end: '\\}\\}'
            }
            {
              name: 'keyword.control.csound'
              match: '\\b(?:do|else(?:if)?|end(?:if|until)|fi|i(?:f|then)|kthen|od|return|then|timout|until|while)\\b'
            }
            {
              begin: '\\b((?:c(?:g|in?|k|n)goto)|goto|igoto|kgoto|loop_(?:g[et]|l[et])|rigoto|tigoto)\\b'
              beginCaptures:
                1:
                  name: 'keyword.control.csound'
              end: '(\\w+)((?://|;).*)?\\n'
              endCaptures:
                1:
                  name: 'entity.name.label.csound'
                2:
                  name: 'comment.line.csound'
              patterns: [
                {
                  include: '#commentsAndMacroCalls'
                }
                {
                  include: '#partialExpressions'
                }
              ]
            }
            {
              begin: '\\b(scoreline(?:_i)?)[ \\t]*(\\{\\{)'
              beginCaptures:
                1:
                  name: 'support.function.csound'
                2:
                  name: 'string.braced.csound'
              end: '\\}\\}'
              endCaptures:
                0:
                  name: 'string.braced.csound'
              patterns: [
                {
                  include: 'source.csound-score'
                }
              ]
            }
            {
              begin: '\\b(pyl?run[it]?)[ \\t]*(\\{\\{)'
              beginCaptures:
                1:
                  name: 'support.function.csound'
                2:
                  name: 'string.braced.csound'
              end: '\\}\\}'
              endCaptures:
                0:
                  name: 'string.braced.csound'
              patterns: [
                {
                  include: 'source.python'
                }
              ]
            }
            {
              begin: '\\b(lua_(?:exec|opdef))[ \\t]*(\\{\\{)'
              beginCaptures:
                1:
                  name: 'support.function.csound'
                2:
                  name: 'string.braced.csound'
              end: '\\}\\}'
              endCaptures:
                0:
                  name: 'string.braced.csound'
              patterns: [
                {
                  include: 'source.lua'
                }
              ]
            }
            {
              name: 'meta.autocompletion.csound'
              match: '(\\[[aikpSw]+\\])\\w*\\b'
              captures:
                1:
                  name: 'storage.type.csound'
            }
            {
              name: 'meta.other.csound'
              match: '\\b[a-zA-Z_]\\w*\\b'
            }
          ]

    super registry, options

    @userDefinedOpcodesByTextEditors = {}

  createPattern: (options) ->
    new CsoundOrchestraGrammarPattern this, @registry, options

  userDefinedOpcodesForTextEditor: (editor) ->
    userDefinedOpcodes = @userDefinedOpcodesByTextEditors[editor]

    unless userDefinedOpcodes?
      userDefinedOpcodes = []
      @userDefinedOpcodesByTextEditors[editor] = userDefinedOpcodes

      @subscriptions = new CompositeDisposable
      @subscriptions.add editor.buffer.onWillChange (event) ->
        # This is calling a private method (bufferRangeForScopeAtPosition) of a
        # private property (displayBuffer) of a TextEditor.
        range = editor.displayBuffer.bufferRangeForScopeAtPosition 'entity.name.function.opcode.csound', event.oldRange.start

        if range
          index = userDefinedOpcodes.indexOf(editor.getTextInBufferRange range)
          if index > -1
            userDefinedOpcodes.splice index, 1
            # This re-tokenizes an entire orchestra when a user-defined opcode
            # is edited. This is jarring, but there does not appear to be a more
            # elegant alternative.
            editor.displayBuffer.tokenizedBuffer.retokenizeLines()

    userDefinedOpcodes
