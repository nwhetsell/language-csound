{CompositeDisposable} = require 'atom'
# The first-mate module does not export the Pattern class.
path = require 'path'
Pattern = require path.join(atom.config.resourcePath, 'node_modules', 'first-mate', 'lib', 'pattern.js')

module.exports =
class CsoundOrchestraGrammarPattern extends Pattern
  @subscriptions = new CompositeDisposable
  @userDefinedOpcodesByTextEditorIDs = {}

  @userDefinedOpcodesForTextEditor: (editor) ->
    return unless editor

    userDefinedOpcodes = @userDefinedOpcodesByTextEditorIDs[editor.id]

    unless userDefinedOpcodes
      userDefinedOpcodes = []
      @userDefinedOpcodesByTextEditorIDs[editor.id] = userDefinedOpcodes

      @subscriptions.add editor.buffer.onWillChange((event) ->
        # This is calling a private method (bufferRangeForScopeAtPosition) of a
        # private property (displayBuffer) of a TextEditor.
        displayBuffer = editor.displayBuffer
        range = displayBuffer.bufferRangeForScopeAtPosition 'entity.name.function.opcode.csound', event.oldRange.start

        if range
          index = userDefinedOpcodes.indexOf editor.getTextInBufferRange(range)
          if index >= 0
            userDefinedOpcodes.splice index, 1
            displayBuffer.tokenizedBuffer.invalidateRow row for row in [0...editor.getLineCount()] when !editor.isBufferRowCommented(row)
      )

    userDefinedOpcodes

  handleMatch: (stack, line, captureIndicesArray, rule, endPatternMatch) ->
    tags = super

    userDefinedOpcodes = CsoundOrchestraGrammarPattern.userDefinedOpcodesForTextEditor atom.workspace.getActiveTextEditor()

    # Handle a Csound name as a user-defined opcode, or variable with a
    # storage-type prefix.
    captureIndicesArrayIndex = captureIndicesArray.length
    for tag, index in tags by -1
      # Odd negative numbers are begin-scope tags.
      if (tag % 2) is -1
        captureIndicesArrayIndex--
        switch @registry.scopeForId tag
          when 'entity.name.function.opcode.csound'
            # Note names of user-defined opcodes so they can be scoped as
            # function names.
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            userDefinedOpcodes.push line.substring(captureIndices.start, captureIndices.end)
          when 'meta.other.csound'
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            substring = line.substring captureIndices.start, captureIndices.end
            if userDefinedOpcodes and substring in userDefinedOpcodes
              # The substring is a user-defined opcode.
              @setTagAtIndexToScope tags, index, 'entity.name.function.opcode.csound'
            else
              result = /^g?[aikpSw]/.exec substring
              if result
                # The substring begins with a storage-type prefix.
                length = result[0].length
                tags[index + 1] -= length
                scope = 'storage.type.csound'
                tags.splice index, 0, @registry.startIdForScope(scope), length, @registry.endIdForScope(scope)
    tags

  setTagAtIndexToScope: (tags, index, scope) ->
    tags[index] = @registry.startIdForScope scope
    tags[index + 2] = @registry.endIdForScope scope
