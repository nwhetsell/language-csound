describe "language-csound", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage "language-csound"

  describe "Csound grammar", ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName "source.csound"

    it "is defined", ->
      expect(grammar.scopeName).toBe "source.csound"

    it "tokenizes comments", ->
      lines = grammar.tokenizeLines """
        /*
         * comment
         */
        ; comment
        // comment
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: " * comment", scopes: ["source.csound", "comment.block.csound"]
      tokens = lines[2]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: " ", scopes: ["source.csound", "comment.block.csound"]
      expect(tokens[1]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      tokens = lines[3]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: ";", scopes: ["source.csound", "comment.line.semicolon.csound", "punctuation.definition.comment.csound"]
      expect(tokens[1]).toEqual value: " comment", scopes: ["source.csound", "comment.line.semicolon.csound"]
      tokens = lines[4]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "//", scopes: ["source.csound", "comment.line.double-slash.csound", "punctuation.definition.comment.csound"]
      expect(tokens[1]).toEqual value: " comment", scopes: ["source.csound", "comment.line.double-slash.csound"]

    it "tokenizes instrument blocks", ->
      lines = grammar.tokenizeLines """
        instr/**/1,/**/N_a_M_e_,/**/+Name//
        aLabel:
          iDuration = p3
        endin
      """

      tokens = lines[0]
      expect(tokens.length).toBe 15
      expect(tokens[0]).toEqual value: "instr", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "keyword.function.csound"]
      expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      expect(tokens[3]).toEqual value: "1", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "entity.name.function.csound"]
      expect(tokens[4]).toEqual value: ",", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound"]
      expect(tokens[5]).toEqual value: "/*", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[6]).toEqual value: "*/", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      expect(tokens[7]).toEqual value: "N_a_M_e_", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "entity.name.function.csound"]
      expect(tokens[8]).toEqual value: ",", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound"]
      expect(tokens[9]).toEqual value: "/*", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[10]).toEqual value: "*/", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      expect(tokens[11]).toEqual value: "+", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound"]
      expect(tokens[12]).toEqual value: "Name", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "entity.name.function.csound"]
      expect(tokens[13]).toEqual value: "//", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound", "comment.line.double-slash.csound", "punctuation.definition.comment.csound"]
      expect(tokens[14]).toEqual value: "", scopes: ["source.csound", "meta.instrument-block.csound", "meta.instrument-declaration.csound"]

      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "aLabel", scopes: ["source.csound", "meta.instrument-block.csound", "entity.name.label.csound"]
      expect(tokens[1]).toEqual value: ":", scopes: ["source.csound", "meta.instrument-block.csound", "entity.punctuation.label.csound"]

      tokens = lines[2]
      expect(tokens.length).toBe 7
      expect(tokens[1]).toEqual value: "i", scopes: ["source.csound", "meta.instrument-block.csound", "storage.type.csound"]
      expect(tokens[2]).toEqual value: "Duration", scopes: ["source.csound", "meta.instrument-block.csound", "meta.other.csound"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.csound", "meta.instrument-block.csound"]
      expect(tokens[4]).toEqual value: "=", scopes: ["source.csound", "meta.instrument-block.csound", "keyword.operator.csound"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.csound", "meta.instrument-block.csound"]
      expect(tokens[6]).toEqual value: "p3", scopes: ["source.csound", "meta.instrument-block.csound", "support.variable.csound"]

      tokens = lines[3]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "endin", scopes: ["source.csound", "meta.instrument-block.csound", "keyword.other.csound"]

    it "tokenizes user-defined opcodes", ->
      # The Csound grammar relies on the existence of an active text editor to
      # tokenize user-defined opcodes.
      waitsForPromise ->
        atom.workspace.open().then (editor) ->
          lines = grammar.tokenizeLines """
            opcode/**/aUDO,/**/ai[]k[],/**/0//
              aUDO
            endop
          """

          tokens = lines[0]
          expect(tokens.length).toBe 14
          expect(tokens[0]).toEqual value: "opcode", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "keyword.function.csound"]
          expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
          expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
          expect(tokens[3]).toEqual value: "aUDO", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "entity.name.function.opcode.csound"]
          expect(tokens[4]).toEqual value: ",", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound"]
          expect(tokens[5]).toEqual value: "/*", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
          expect(tokens[6]).toEqual value: "*/", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
          expect(tokens[7]).toEqual value: "ai[]k[]", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "meta.opcode-type-signature.csound", "storage.type.csound"]
          expect(tokens[8]).toEqual value: ",", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "meta.opcode-type-signature.csound"]
          expect(tokens[9]).toEqual value: "/*", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
          expect(tokens[10]).toEqual value: "*/", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
          expect(tokens[11]).toEqual value: "0", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "meta.opcode-type-signature.csound", "storage.type.csound"]
          expect(tokens[12]).toEqual value: "//", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound", "meta.opcode-details.csound", "meta.opcode-type-signature.csound", "comment.line.double-slash.csound", "punctuation.definition.comment.csound"]
          expect(tokens[13]).toEqual value: "", scopes: ["source.csound", "meta.opcode-definition.csound", "meta.opcode-declaration.csound"]

          tokens = lines[1]
          expect(tokens.length).toBe 2
          expect(tokens[0]).toEqual value: "  ", scopes: ["source.csound", "meta.opcode-definition.csound"]
          expect(tokens[1]).toEqual value: "aUDO", scopes: ["source.csound", "meta.opcode-definition.csound", "entity.name.function.opcode.csound"]

          tokens = lines[2]
          expect(tokens.length).toBe 1
          expect(tokens[0]).toEqual value: "endop", scopes: ["source.csound", "meta.opcode-definition.csound", "keyword.other.csound"]

    it "tokenizes numbers", ->
      lines = grammar.tokenizeLines """
        123
        0123456789
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "123", scopes: ["source.csound", "constant.numeric.integer.decimal.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "0123456789", scopes: ["source.csound", "constant.numeric.integer.decimal.csound"]

      lines = grammar.tokenizeLines """
        0xabcdef0123456789
        0XABCDEF
      """
      tokens = lines[0]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "0x", scopes: ["source.csound", "storage.type.number.csound"]
      expect(tokens[1]).toEqual value: "abcdef0123456789", scopes: ["source.csound", "constant.numeric.integer.hexadecimal.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "0X", scopes: ["source.csound", "storage.type.number.csound"]
      expect(tokens[1]).toEqual value: "ABCDEF", scopes: ["source.csound", "constant.numeric.integer.hexadecimal.csound"]

      floats = [
        "1e2"
        "3e+4"
        "5e-6"
        "7E8"
        "9E+0"
        "1E-2"
        "3."
        "4.56"
        ".789"
      ]
      lines = grammar.tokenizeLines(floats.join "\n")
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: floats[i], scopes: ["source.csound", "constant.numeric.float.csound"]

    it "tokenizes quoted strings", ->
      {tokens} = grammar.tokenizeLine '"characters$MACRO."'
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.begin.csound"]
      expect(tokens[1]).toEqual value: "characters", scopes: ["source.csound", "string.quoted.csound"]
      expect(tokens[2]).toEqual value: "$MACRO.", scopes: ["source.csound", "string.quoted.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[3]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.end.csound"]

      lines = grammar.tokenizeLines """
        "error
        ok"
      """
      tokens = lines[0]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.begin.csound"]
      expect(tokens[1]).toEqual value: "error", scopes: ["source.csound", "string.quoted.csound", "invalid.illegal.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "ok", scopes: ["source.csound", "string.quoted.csound"]
      expect(tokens[1]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.end.csound"]

      lines = grammar.tokenizeLines """
        "chara\\ ;comment
        cters"
      """
      tokens = lines[0]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.begin.csound"]
      expect(tokens[1]).toEqual value: "chara", scopes: ["source.csound", "string.quoted.csound"]
      expect(tokens[2]).toEqual value: "\\", scopes: ["source.csound", "string.quoted.csound", "meta.line-continuation.csound", "constant.character.escape.line-continuation.csound"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.csound", "string.quoted.csound", "meta.line-continuation.csound"]
      expect(tokens[4]).toEqual value: ";", scopes: ["source.csound", "string.quoted.csound", "meta.line-continuation.csound", "comment.line.semicolon.csound", "punctuation.definition.comment.csound"]
      expect(tokens[5]).toEqual value: "comment", scopes: ["source.csound", "string.quoted.csound", "meta.line-continuation.csound", "comment.line.semicolon.csound"]
      expect(tokens[6]).toEqual value: "", scopes: ["source.csound", "string.quoted.csound", "meta.line-continuation.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "cters", scopes: ["source.csound", "string.quoted.csound"]
      expect(tokens[1]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.end.csound"]

    it "tokenizes braced strings", ->
      lines = grammar.tokenizeLines """
        {{
        characters$MACRO.
        }}
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "{{", scopes: ["source.csound", "string.braced.csound"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "characters$MACRO.", scopes: ["source.csound", "string.braced.csound"]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "}}", scopes: ["source.csound", "string.braced.csound"]

    it "tokenizes escape sequences", ->
      escapeSequences = [
        "\\\\"
        "\\a"
        "\\b"
        "\\n"
        "\\r"
        "\\t"
        '\\"'
        "\\012"
        "\\345"
        "\\67"
      ]
      {tokens} = grammar.tokenizeLine "\"#{escapeSequences.join ""}\""
      for i in [1...tokens.length - 1]
        expect(tokens[i]).toEqual value: escapeSequences[i - 1], scopes: ["source.csound", "string.quoted.csound", "constant.character.escape.csound"]
      {tokens} = grammar.tokenizeLine "{{#{escapeSequences.join ""}}}"
      for i in [1...tokens.length - 1]
        expect(tokens[i]).toEqual value: escapeSequences[i - 1], scopes: ["source.csound", "string.braced.csound", "constant.character.escape.csound"]

    it "tokenizes operators", ->
      operators = [
        "+"
        "-"
        "~", "¬"
        "!"
        "*"
        "/"
        "^"
        "%"
        "<<"
        ">>"
        "<"
        ">"
        "<="
        ">="
        "=="
        "!="
        "&"
        "#"
        "|"
        "&&"
        "||"
        "?", ":"
        "+="
        "-="
        "*="
        "/="
      ]
      lines = grammar.tokenizeLines(operators.join "\n")
      expect(lines.length).toBe operators.length
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: operators[i], scopes: ["source.csound", "keyword.operator.csound"]

    it "tokenizes global value identifiers", ->
      globalValueIdentifiers = [
        "0dbfs"
        "A4"
        "kr"
        "ksmps"
        "nchnls"
        "nchnls_i"
        "sr"
      ]
      lines = grammar.tokenizeLines(globalValueIdentifiers.join "\n")
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: globalValueIdentifiers[i], scopes: ["source.csound", "variable.other.readwrite.global.csound"]

    it "tokenizes keywords", ->
      keywords = [
        "do"
        "else"
        "elseif"
        "endif"
        "enduntil"
        "fi"
        "if"
        "ithen"
        "kthen"
        "od"
        "return"
        "rireturn"
        "then"
        "until"
        "while"
      ]
      lines = grammar.tokenizeLines(keywords.join "\n")
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: keywords[i], scopes: ["source.csound", "keyword.control.csound"]

    it "tokenizes printks and prints escape sequences", ->
      opcodes = [
        "printks"
        "prints"
      ]
      escapeSequences = [
        "%!"
        "%%"
        "%n"
        "%N"
        "%r"
        "%R"
        "%t"
        "%T"
        "\\\\a"
        "\\\\A"
        "\\\\b"
        "\\\\B"
        "\\\\n"
        "\\\\N"
        "\\\\r"
        "\\\\R"
        "\\\\t"
        "\\\\T"
      ]
      for opcode in opcodes
        {tokens} = grammar.tokenizeLine "#{opcode} \"#{escapeSequences.join ""}\""
        expect(tokens[0]).toEqual value: opcode, scopes: ["source.csound", "support.function.csound"]
        expect(tokens[1]).toEqual value: " ", scopes: ["source.csound"]
        expect(tokens[2]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.begin.csound"]
        for i in [3...tokens.length - 1]
          expect(tokens[i]).toEqual value: escapeSequences[i - 3], scopes: ["source.csound", "string.quoted.csound", "constant.character.escape.csound"]
        expect(tokens[tokens.length - 1]).toEqual value: '"', scopes: ["source.csound", "string.quoted.csound", "punctuation.definition.string.end.csound"]

    it "tokenizes goto statements", ->
      keywordsAndOpcodes = [
        "cggoto"
        "cigoto"
        "cingoto"
        "ckgoto"
        "cngoto"
        "goto"
        "igoto"
        "kgoto"
        "loop_ge"
        "loop_gt"
        "loop_le"
        "loop_lt"
        "reinit"
        "rigoto"
        "tigoto"
        "timout"
        ""
      ]
      # Putting a label after each string is enough to test the grammar, but
      # it’s not always valid Csound syntax. In particular, loop_ge, loop_gt,
      # loop_le, and loop_lt all take four arguments, the last of which is a
      # label.
      lines = grammar.tokenizeLines(keywordsAndOpcodes.join " aLabel //\n")
      for i in [0...lines.length - 1]
        tokens = lines[i]
        expect(tokens[0]).toEqual value: keywordsAndOpcodes[i], scopes: ["source.csound", "keyword.control.csound"]
        expect(tokens[1]).toEqual value: " ", scopes: ["source.csound"]
        expect(tokens[2]).toEqual value: "aLabel", scopes: ["source.csound", "entity.name.label.csound"]
        expect(tokens[3]).toEqual value: " ", scopes: ["source.csound"]
        expect(tokens[4]).toEqual value: "//", scopes: ["source.csound", "comment.line.double-slash.csound", "punctuation.definition.comment.csound"]

    it "tokenizes include directives", ->
      for character in ['"', "|"]
        {tokens} = grammar.tokenizeLine "#include/**/#{character}file.udo#{character}"
        expect(tokens.length).toBe 7
        expect(tokens[0]).toEqual value: "#include", scopes: ["source.csound", "keyword.include.preprocessor.csound"]
        expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
        expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
        expect(tokens[3]).toEqual value: character, scopes: ["source.csound", "string.include.csound", "punctuation.definition.string.begin.csound"]
        expect(tokens[4]).toEqual value: "file.udo", scopes: ["source.csound", "string.include.csound"]
        expect(tokens[5]).toEqual value: character, scopes: ["source.csound", "string.include.csound", "punctuation.definition.string.end.csound"]
        expect(tokens[6]).toEqual value: "", scopes: ["source.csound"]

    it "tokenizes object-like macro definitions", ->
      lines = grammar.tokenizeLines """
        # \tdefineMACRO#macro_body#
        #define/**/
        MACRO/**/
        #\\#macro
        body\\##
      """

      tokens = lines[0]
      expect(tokens.length).toBe 5
      expect(tokens[0]).toEqual value: "# \tdefine", scopes: ["source.csound", "keyword.define.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "MACRO", scopes: ["source.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[2]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.begin.csound"]
      expect(tokens[3]).toEqual value: "macro_body", scopes: ["source.csound", "meta.other.csound"]
      expect(tokens[4]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.end.csound"]

      tokens = lines[1]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "#define", scopes: ["source.csound", "keyword.define.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      tokens = lines[2]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "MACRO", scopes: ["source.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      tokens = lines[3]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.begin.csound"]
      expect(tokens[1]).toEqual value: "\\#", scopes: ["source.csound", "constant.character.escape.csound"]
      expect(tokens[2]).toEqual value: "macro", scopes: ["source.csound", "meta.other.csound"]
      tokens = lines[4]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "body", scopes: ["source.csound", "meta.other.csound"]
      expect(tokens[1]).toEqual value: "\\#", scopes: ["source.csound", "constant.character.escape.csound"]
      expect(tokens[2]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.end.csound"]

    it "tokenizes function-like macro definitions", ->
      lines = grammar.tokenizeLines """
        #defineMACRO(ARG1#ARG2)#macro_body#
        #define/**/
        MACRO(ARG1'ARG2'ARG3)/**/
        #\\#macro
        body\\##
      """

      tokens = lines[0]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: "#define", scopes: ["source.csound", "keyword.define.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "MACRO", scopes: ["source.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[2]).toEqual value: "(", scopes: ["source.csound"]
      expect(tokens[3]).toEqual value: "ARG1", scopes: ["source.csound", "variable.parameter.preprocessor.csound"]
      expect(tokens[4]).toEqual value: "#", scopes: ["source.csound"]
      expect(tokens[5]).toEqual value: "ARG2", scopes: ["source.csound", "variable.parameter.preprocessor.csound"]
      expect(tokens[6]).toEqual value: ")", scopes: ["source.csound"]
      expect(tokens[7]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.begin.csound"]
      expect(tokens[8]).toEqual value: "macro_body", scopes: ["source.csound", "meta.other.csound"]
      expect(tokens[9]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.end.csound"]

      tokens = lines[1]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "#define", scopes: ["source.csound", "keyword.define.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[2]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      tokens = lines[2]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: "MACRO", scopes: ["source.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "(", scopes: ["source.csound"]
      expect(tokens[2]).toEqual value: "ARG1", scopes: ["source.csound", "variable.parameter.preprocessor.csound"]
      expect(tokens[3]).toEqual value: "'", scopes: ["source.csound"]
      expect(tokens[4]).toEqual value: "ARG2", scopes: ["source.csound", "variable.parameter.preprocessor.csound"]
      expect(tokens[5]).toEqual value: "'", scopes: ["source.csound"]
      expect(tokens[6]).toEqual value: "ARG3", scopes: ["source.csound", "variable.parameter.preprocessor.csound"]
      expect(tokens[7]).toEqual value: ")", scopes: ["source.csound"]
      expect(tokens[8]).toEqual value: "/*", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.begin.csound"]
      expect(tokens[9]).toEqual value: "*/", scopes: ["source.csound", "comment.block.csound", "punctuation.definition.comment.end.csound"]
      tokens = lines[3]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.begin.csound"]
      expect(tokens[1]).toEqual value: "\\#", scopes: ["source.csound", "constant.character.escape.csound"]
      expect(tokens[2]).toEqual value: "macro", scopes: ["source.csound", "meta.other.csound"]
      tokens = lines[4]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "body", scopes: ["source.csound", "meta.other.csound"]
      expect(tokens[1]).toEqual value: "\\#", scopes: ["source.csound", "constant.character.escape.csound"]
      expect(tokens[2]).toEqual value: "#", scopes: ["source.csound", "punctuation.definition.macro.end.csound"]

    it "tokenizes macro preprocessor directives", ->
      preprocessorDirectives = [
        "#ifdef"
        "#ifndef"
        "#undef"
        ""
      ]
      lines = grammar.tokenizeLines(preprocessorDirectives.join " MACRO\n")
      for i in [0...lines.length - 1]
        tokens = lines[i]
        expect(tokens.length).toBe 4
        expect(tokens[0]).toEqual value: preprocessorDirectives[i], scopes: ["source.csound", "keyword.preprocessor.csound"]
        expect(tokens[1]).toEqual value: " ", scopes: ["source.csound"]
        expect(tokens[2]).toEqual value: "MACRO", scopes: ["source.csound", "entity.name.function.preprocessor.csound"]
        expect(tokens[3]).toEqual value: "", scopes: ["source.csound"]

    it "tokenizes other preprocessor directives", ->
      preprocessorDirectives = [
        "#else"
        "#end"
        "#endif"
        "###"
        "@ \t0"
        "@@ \t0"
      ]
      lines = grammar.tokenizeLines(preprocessorDirectives.join "\n")
      for i in [0...lines.length]
        expect(lines[i][0]).toEqual value: preprocessorDirectives[i], scopes: ["source.csound", "keyword.preprocessor.csound"]

    it "tokenizes function-like macros", ->
      {tokens} = grammar.tokenizeLine '$MACRO.(((x\\))\' "x)\\)x\\))"# {{x\\))x)\\)}});'
      expect(tokens.length).toBe 29
      expect(tokens[0]).toEqual value: "$MACRO.", scopes: ["source.csound", "meta.function-like-macro-use.csound", "entity.name.function.preprocessor.csound"]
      expect(tokens[1]).toEqual value: "(", scopes: ["source.csound", "meta.function-like-macro-use.csound"]
      expect(tokens[2]).toEqual value: "(", scopes: ["source.csound", "meta.function-like-macro-use.csound", "meta.macro-parameter-value-parenthetical.csound", "constant.character.escape.csound"]
      expect(tokens[3]).toEqual value: "(", scopes: ["source.csound", "meta.function-like-macro-use.csound", "meta.macro-parameter-value-parenthetical.csound", "meta.macro-parameter-value-parenthetical.csound", "constant.character.escape.csound"]
      expect(tokens[4]).toEqual value: "x", scopes: ["source.csound", "meta.function-like-macro-use.csound", "meta.macro-parameter-value-parenthetical.csound", "meta.macro-parameter-value-parenthetical.csound", "meta.other.csound"]
      expect(tokens[5]).toEqual value: "\\)", scopes: ["source.csound", "meta.function-like-macro-use.csound", "meta.macro-parameter-value-parenthetical.csound", "meta.macro-parameter-value-parenthetical.csound", "constant.character.escape.csound"]
      expect(tokens[6]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound", "meta.macro-parameter-value-parenthetical.csound", "invalid.illegal.csound"]
      expect(tokens[7]).toEqual value: "'", scopes: ["source.csound", "meta.function-like-macro-use.csound", "punctuation.macro-parameter-separator.csound"]
      expect(tokens[8]).toEqual value: " ", scopes: ["source.csound", "meta.function-like-macro-use.csound"]
      expect(tokens[9]).toEqual value: '"', scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "punctuation.definition.string.begin.csound"]
      expect(tokens[10]).toEqual value: "x", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound"]
      expect(tokens[11]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "invalid.illegal.csound"]
      expect(tokens[12]).toEqual value: "\\)", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "constant.character.escape.csound"]
      expect(tokens[13]).toEqual value: "x", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound"]
      expect(tokens[14]).toEqual value: "\\)", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "constant.character.escape.csound"]
      expect(tokens[15]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "invalid.illegal.csound"]
      expect(tokens[16]).toEqual value: '"', scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.quoted.csound", "punctuation.definition.string.end.csound"]
      expect(tokens[17]).toEqual value: "#", scopes: ["source.csound", "meta.function-like-macro-use.csound", "punctuation.macro-parameter-separator.csound"]
      expect(tokens[18]).toEqual value: " ", scopes: ["source.csound", "meta.function-like-macro-use.csound"]
      expect(tokens[19]).toEqual value: "{{", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound"]
      expect(tokens[20]).toEqual value: "x", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound"]
      expect(tokens[21]).toEqual value: "\\)", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound", "constant.character.escape.csound"]
      expect(tokens[22]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound", "invalid.illegal.csound"]
      expect(tokens[23]).toEqual value: "x", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound"]
      expect(tokens[24]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound", "invalid.illegal.csound"]
      expect(tokens[25]).toEqual value: "\\)", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound", "constant.character.escape.csound"]
      expect(tokens[26]).toEqual value: "}}", scopes: ["source.csound", "meta.function-like-macro-use.csound", "string.braced.csound"]
      expect(tokens[27]).toEqual value: ")", scopes: ["source.csound", "meta.function-like-macro-use.csound"]
      expect(tokens[28]).toEqual value: ";", scopes: ["source.csound", "comment.line.semicolon.csound", "punctuation.definition.comment.csound"]


  describe "Csound Score grammar", ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName "source.csound-score"

    it "is defined", ->
      expect(grammar.scopeName).toBe "source.csound-score"

    it "tokenizes mark statements", ->
      lines = grammar.tokenizeLines """
        m mark
        n mark
      """
      tokens = lines[0]
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: "m", scopes: ["source.csound-score", "keyword.mark.preprocessor.csound-score"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.csound-score"]
      expect(tokens[2]).toEqual value: "mark", scopes: ["source.csound-score", "entity.name.label.csound-score"]
      expect(tokens[3]).toEqual value: "", scopes: ["source.csound-score"]
      tokens = lines[1]
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: "n", scopes: ["source.csound-score", "keyword.repeat-mark.preprocessor.csound-score"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.csound-score"]
      expect(tokens[2]).toEqual value: "mark", scopes: ["source.csound-score", "entity.name.label.csound-score"]
      expect(tokens[3]).toEqual value: "", scopes: ["source.csound-score"]

    it "tokenizes repeat section statements", ->
      {tokens} = grammar.tokenizeLine "r 1 MACRO\n"
      expect(tokens.length).toBe 6
      expect(tokens[0]).toEqual value: "r", scopes: ["source.csound-score", "keyword.repeat-section.preprocessor.csound-score"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.csound-score"]
      expect(tokens[2]).toEqual value: "1", scopes: ["source.csound-score", "constant.numeric.integer.decimal.csound-score"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.csound-score"]
      expect(tokens[4]).toEqual value: "MACRO", scopes: ["source.csound-score", "entity.name.function.preprocessor.csound"]
      expect(tokens[5]).toEqual value: "\n", scopes: ["source.csound-score"]

    it "tokenizes other score statements", ->
      scoreStatements = [
        "a" # advance
        "b" # beat offset
        "C" # carry
        "d" # delete
        "e" # end
        "f" # function table
        "i" # instrument
        "q" # quiet
        "s" # section end
        "t" # tempo
        "v" # local tempo
        "x" # skip
        "y" # random number generator seed
      ]
      lines = grammar.tokenizeLines(scoreStatements.join "\n")
      for i in [0...lines.length]
        tokens = lines[i]
        expect(tokens.length).toBe 1
        expect(tokens[0]).toEqual value: scoreStatements[i], scopes: ["source.csound-score", "keyword.control.csound-score"]
      {tokens} = grammar.tokenizeLine "w"
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "w", scopes: ["source.csound-score", "invalid.illegal.csound-score"]
      {tokens} = grammar.tokenizeLine "z"
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "z", scopes: ["source.csound-score", "constant.numeric.language.csound-score"]

    it "tokenizes next-p and previous-p symbols", ->
      scoreStatements = [
        "np1"
        "nP2"
        "Np3"
        "NP4"
      ]
      lines = grammar.tokenizeLines(scoreStatements.join "\n")
      i = 1
      for token in ["np", "nP", "Np", "NP"]
        {tokens} = grammar.tokenizeLine token + i
        expect(tokens.length).toBe 2
        expect(tokens[0]).toEqual value: token, scopes: ["source.csound-score", "meta.p-symbol.csound-score", "keyword.control.csound-score"]
        expect(tokens[1]).toEqual value: i.toString(), scopes: ["source.csound-score", "meta.p-symbol.csound-score", "constant.numeric.integer.decimal.csound-score"]
        i++

    it "tokenizes braced loops", ->
      lines = grammar.tokenizeLines """
        { 10 I
        }
      """
      tokens = lines[0]
      expect(tokens.length).toBe 6
      expect(tokens[0]).toEqual value: "{", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "punctuation.csound-score"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score"]
      expect(tokens[2]).toEqual value: "10", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score", "constant.numeric.integer.decimal.csound-score"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score"]
      expect(tokens[4]).toEqual value: "I", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score", "entity.name.function.preprocessor.csound-score"]
      expect(tokens[5]).toEqual value: "", scopes: ["source.csound-score", "meta.braced-loop.csound-score"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "}", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "punctuation.csound-score"]

      lines = grammar.tokenizeLines """
        { 3 $FOO
        }
      """
      tokens = lines[0]
      expect(tokens.length).toBe 6
      expect(tokens[0]).toEqual value: "{", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "punctuation.csound-score"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score"]
      expect(tokens[2]).toEqual value: "3", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score", "constant.numeric.integer.decimal.csound-score"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score"]
      expect(tokens[4]).toEqual value: "$FOO", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "meta.braced-loop-details.csound-score", "invalid.illegal.csound-score"]
      expect(tokens[5]).toEqual value: "", scopes: ["source.csound-score", "meta.braced-loop.csound-score"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "}", scopes: ["source.csound-score", "meta.braced-loop.csound-score", "punctuation.csound-score"]


  describe "Csound Document grammar", ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName "source.csound-document"

    it "is defined", ->
      expect(grammar.scopeName).toBe "source.csound-document"

    it "tokenizes Cabbage widget types", ->
      # https://github.com/rorywalsh/cabaiste/search?q=CabbageControlWidgetStrings+path%3ASource+filename%3ACabbageIds.h
      widgetTypes = [
        "button"
        "checkbox"
        "combobox"
        "encoder"
        "hrange"
        "hslider"
        "numberbox"
        "rslider"
        "vrange"
        "vslider"
        "xypad"
      ]
      deprecatedWidgetTypes = [
        "hslider2"
        "hslider3"
        "vslider2"
        "vslider3"
      ]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (widgetTypes.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe widgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetTypes[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "keyword.widget-type.cabbage-gui.csound-document"]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (deprecatedWidgetTypes.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe deprecatedWidgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetTypes[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "invalid.deprecated.cabbage-gui.csound-document"]

      # https://github.com/rorywalsh/cabaiste/search?q=CabbageLayoutWidgetStrings+path%3ASource+filename%3ACabbageIds.h
      widgetTypes = [
        "csoundoutput"
        "filebutton"
        "form"
        "gentable"
        "groupbox"
        "hostbpm"
        "hostplaying"
        "hostppqpos"
        "hosttime"
        "image"
        "infobutton"
        "keyboard"
        "label"
        "line"
        "loadbutton"
        "signaldisplay"
        "socketreceive"
        "socketsend"
        "soundfiler"
        "source"
        "stepper"
        "textbox"
        "texteditor"
      ]
      deprecatedWidgetTypes = [
        "directorylist"
        "fftdisplay"
        "hostrecording"
        "listbox"
        "multitab"
        "patmatrix"
        "popupmenu"
        "pvsview"
        "recordbutton"
        "snapshot"
        "sourcebutton"
        "table"
        "transport"
      ]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (widgetTypes.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe widgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetTypes[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "keyword.widget-type.cabbage-gui.csound-document"]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (deprecatedWidgetTypes.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe deprecatedWidgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetTypes[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "invalid.deprecated.cabbage-gui.csound-document"]

    it "tokenizes Cabbage widget identifiers", ->
      # https://github.com/rorywalsh/cabaiste/search?q=CabbageIdentifierStrings+path%3ASource+filename%3ACabbageIds.h
      widgetIdentifiers = [
        "active"
        "address"
        "align"
        "alpha"
        "amprange"
        "arrowbackgroundcolour"
        "arrowcolour"
        "backgroundcolor"
        "backgroundcolour"
        "ballcolour"
        "blacknotecolour"
        "bounds"
        "caption"
        "channel"
        "channelarray"
        "channels"
        "channeltype"
        "color:0"
        "color:1"
        "color"
        "colour:0"
        "colour:1"
        "colour"
        "corners"
        "displaytype"
        "file"
        "fill"
        "fontcolor:0"
        "fontcolor:1"
        "fontcolor"
        "fontcolour:0"
        "fontcolour:1"
        "fontcolour"
        "fontstyle"
        "guirefresh"
        "highlightcolour"
        "identchannel"
        "imgdebug"
        "imgfile"
        "imgpath"
        "items"
        "keywidth"
        "kind"
        "latched"
        "linethickness"
        "max"
        "menucolor"
        "middlec"
        "min"
        "mode"
        "noteseparatorcolour"
        "numberofsteps"
        "outlinecolor"
        "outlinecolour"
        "outlinethickness"
        "plant"
        "pluginid"
        "populate"
        "popup"
        "popuptext"
        "pos"
        "radiogroup"
        "range"
        "rangex"
        "rangey"
        "refreshfiles"
        "rescale"
        "rotate"
        "samplerange"
        "scrubberposition"
        "shape"
        "show"
        "signalvariable"
        "size"
        "sliderincr"
        "tablebackgroundcolour"
        "tablecolor"
        "tablecolour"
        "tablegridcolor"
        "tablegridcolour"
        "tablenumber"
        "tablenumbers"
        "text"
       #"textbox"
        "textcolor"
        "textcolour"
        "titlebarcolour"
        "trackercolor"
        "trackercolour"
        "trackerthickness"
        "updaterate"
        "value"
        "valuetextbox"
        "velocity"
        "visible"
        "whitenotecolour"
        "widgetarray"
        "wrap"
        "zoom"
      ]
      deprecatedWidgetIdentifiers = [
        "bold"
        "ffttablenumber"
        "gradient"
        "logger"
        "scalex"
        "scaley"
        "scroll"
        "scrollbars"
        "tablebackgroundcolor"
      ]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (widgetIdentifiers.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe widgetIdentifiers.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetIdentifiers[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "support.function.widget-identifier.cabbage-gui.csound-document"]
      lines = grammar.tokenizeLines(
        "<Cabbage>\n" +
        (deprecatedWidgetIdentifiers.join "\n") +
        "</Cabbage>\n"
      )
      expect(lines.length - 2).toBe deprecatedWidgetIdentifiers.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetIdentifiers[i - 1], scopes: ["source.csound-document", "meta.cabbage-gui.csound-document", "invalid.deprecated.cabbage-gui.csound-document"]
