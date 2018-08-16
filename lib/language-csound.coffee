{CompositeDisposable} = require('atom')
fs = require('fs')
path = require('path')

module.exports =
LanguageCsound = {
  activate: (state) ->
    @subscriptions = new CompositeDisposable

    callback = (grammar) ->
      if grammar.scopeName is 'source.csound'
        grammar.rawRepository.partialExpressions.patterns.splice(-1, 0, {
          name:  'meta.autocompletion.csound'
          match: '(\\([afikSw|]+\\))\\w*\\b'
          captures: 1: name: 'storage.type.csound'
        })
    grammar = atom.grammars.grammarForScopeName('source.csound')
    if grammar
      callback(grammar)
    else
      @subscriptions.add(atom.grammars.onDidAddGrammar(callback))

  deactivate: ->
    @subscriptions.dispose()

  providers: -> {
    selector: '.source.csound'
    disableForSelector: '.source.csound .comment, .source.csound .line-continuation, .source.csound .string'
    filterSuggestions: true

    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
      if @completions
        return @completions
      new Promise((resolve) ->
        fs.readFile(path.resolve(__dirname, '..', 'resources', 'opcode-completions.json'), (error, data) ->
          @completions = JSON.parse(data).completions
          resolve @completions
        )
      )
  }
}
