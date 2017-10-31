{CompositeDisposable} = require('atom')
# The first-mate module doesn’t export the Pattern class.
Pattern = require(require('path').join(atom.config.resourcePath, 'node_modules', 'first-mate', 'lib', 'pattern.js'))

module.exports =
class CsoundPattern extends Pattern
  @subscriptions = new CompositeDisposable
  @userDefinedOpcodesByWorkspaceIDs = {}

  @userDefinedOpcodesForWorkspace: (workspace) ->
    return unless workspace

    userDefinedOpcodes = @userDefinedOpcodesByWorkspaceIDs[workspace.id]

    unless userDefinedOpcodes
      userDefinedOpcodes = []
      @userDefinedOpcodesByWorkspaceIDs[workspace.id] = userDefinedOpcodes

      @subscriptions.add workspace.observeTextEditors((editor) =>
        @subscriptions.add editor.buffer.onDidChangeText((event) ->
          for change in event.changes
            # bufferRangeForScopeAtPosition is a private method of TextEditor
            # (https://github.com/atom/atom/search?q=bufferRangeForScopeAtPosition+path%3Asrc+filename%3Atext-editor.coffee)
            range = editor.bufferRangeForScopeAtPosition('entity.name.function.opcode.csound', change.oldRange.start)

            if range
              index = userDefinedOpcodes.indexOf(editor.getTextInBufferRange(range))
              if index >= 0
                userDefinedOpcodes.splice(index, 1)
                # tokenizedBuffer is a private property of TextEditor
                # (https://github.com/atom/atom/search?q=tokenizedBuffer+path%3Asrc+filename%3Atext-editor.coffee)
                # that returns an instance of the private class TokenizedBuffer
                # (https://github.com/atom/atom/search?q=invalidateRow+path%3Asrc+filename%3Atokenized-buffer.coffee)
                for row in [0...editor.getLineCount()] when !editor.isBufferRowCommented(row)
                  editor.tokenizedBuffer.invalidateRow(row)
        )
      )

    userDefinedOpcodes

  handleMatch: (stack, line, captureIndicesArray) ->
    tags = super

    userDefinedOpcodes = CsoundPattern.userDefinedOpcodesForWorkspace(atom.workspace)

    # Handle a Csound name as a user-defined opcode, or a variable with a
    # storage-type prefix.
    captureIndicesArrayIndex = captureIndicesArray.length
    for tag, index in tags by -1
      # Odd negative numbers are begin-scope tags.
      if (tag % 2) is -1
        captureIndicesArrayIndex--
        switch @registry.scopeForId(tag)
          when 'entity.name.function.opcode.csound'
            # Note names of user-defined opcodes so they can be scoped as
            # function names.
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            userDefinedOpcodes.push(line.substring(captureIndices.start, captureIndices.end))
          when 'meta.other.csound'
            captureIndices = captureIndicesArray[captureIndicesArrayIndex]
            substring = line.substring(captureIndices.start, captureIndices.end)
            if userDefinedOpcodes and substring in userDefinedOpcodes
              # The substring is a user-defined opcode.
              @setTagAtIndexToScope(tags, index, 'entity.name.function.opcode.csound')
            else
              result = /^g?[afikSw]/.exec(substring)
              if result
                # The substring begins with a storage-type prefix.
                length = result[0].length
                tags[index + 1] -= length
                scope = 'storage.type.csound'
                tags.splice(index, 0, @registry.startIdForScope(scope), length, @registry.endIdForScope(scope))
    tags

  setTagAtIndexToScope: (tags, index, scope) ->
    tags[index] = @registry.startIdForScope(scope)
    tags[index + 2] = @registry.endIdForScope(scope)
