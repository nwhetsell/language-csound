{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'

CsoundPattern = require './csound-pattern'

module.exports =
LanguageCsound =
  activate: (state) ->
    @subscriptions = new CompositeDisposable

    grammar = atom.grammars.grammarForScopeName 'source.csound'
    callback = (grammar) ->
      return unless grammar.scopeName is 'source.csound'
      grammar.createPattern = (options) ->
        new CsoundPattern(this, @registry, options)
      grammar.rawRepository.partialExpressions.patterns.splice -1, 0, {
        name: 'meta.autocompletion.csound'
        match: '(\\([aikpSw|]+\\))\\w*\\b'
        captures:
          1:
            name: 'storage.type.csound'
      }
    if grammar
      callback grammar
    else
      atom.grammars.onDidAddGrammar callback

  deactivate: ->
    @subscriptions.dispose()

  providers: -> {
    selector: '.source.csound'
    disableForSelector: '.source.csound .comment'
    filterSuggestions: true

    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
      if @completions
        return @completions
      new Promise (resolve) ->
        fs.readFile path.resolve(__dirname, '..', 'resources', 'opcode-completions.json'), (error, data) ->
          @completions = JSON.parse(data).completions
          resolve @completions
  }
