{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'

CsoundOrchestraGrammar = require './csound-orchestra-grammar'

module.exports =
Csound =
  activate: (state) ->
    atom.grammars.addGrammar(new CsoundOrchestraGrammar(atom.grammars))

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
