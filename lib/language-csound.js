const {CompositeDisposable} = require("atom");
const fs = require("fs");
const path = require("path");

module.exports = {
  activate(state) {
    this.subscriptions = new CompositeDisposable();

    function callback(grammar) {
      if (grammar.scopeName === "source.csound") {
        grammar.rawRepository.partialExpressions.patterns.splice(-1, 0, {
          name:  "meta.autocompletion.csound",
          match: "(\\([afikSw|]+\\))\\w*\\b",
          captures: {1: {name: "storage.type.csound"}}
        });
      }
    }
    const grammar = atom.grammars.grammarForScopeName("source.csound");
    if (grammar)
      callback(grammar);
    else
      this.subscriptions.add(atom.grammars.onDidAddGrammar(callback));
  },

  deactivate() {
    this.subscriptions.dispose();
  },

  providers() {
    return {
      selector: ".source.csound",
      disableForSelector: ".source.csound .comment, .source.csound .line-continuation, .source.csound .string",
      filterSuggestions: true,

      getSuggestions({editor, bufferPosition, scopeDescriptor, prefix}) {
        if (this.completions)
          return this.completions;

        return new Promise(resolve => {
          fs.readFile(path.resolve(__dirname, "..", "resources", "opcode-completions.json"), (error, data) => {
            this.completions = JSON.parse(data).completions;
            resolve(this.completions);
          });
        });
      }
    };
  }
};
