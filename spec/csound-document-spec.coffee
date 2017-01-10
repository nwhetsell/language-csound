describe 'language-csound', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage 'language-csound'

  describe 'Csound Document grammar', ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName 'source.csound-document'

    it 'is defined', ->
      expect(grammar.scopeName).toBe 'source.csound-document'

    it 'tokenizes Cabbage widget types', ->
      # https://github.com/rorywalsh/cabaiste/search?q=CabbageControlWidgetStrings+path%3ASource+filename%3ACabbageIds.h
      widgetTypes = [
        'button'
        'checkbox'
        'combobox'
        'encoder'
        'hrange'
        'hslider'
       #'hslider3'
        'numberbox'
        'rslider'
        'vrange'
        'vslider'
       #'vslider3'
        'xypad'
      ]
      deprecatedWidgetTypes = [
        'hslider2'
        'vslider2'
      ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (widgetTypes.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe widgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetTypes[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'keyword.widget-type.cabbage-gui.csound-document'
        ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (deprecatedWidgetTypes.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe deprecatedWidgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetTypes[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'invalid.deprecated.cabbage-gui.csound-document'
        ]

      # https://github.com/rorywalsh/cabaiste/search?q=CabbageLayoutWidgetStrings+path%3ASource+filename%3ACabbageIds.h
      widgetTypes = [
        'csoundoutput'
        'filebutton'
        'form'
        'gentable'
        'groupbox'
        'hostbpm'
        'hostplaying'
        'hostppqpos'
        'hosttime'
        'image'
        'infobutton'
        'keyboard'
        'label'
        'line'
        'loadbutton'
        'signaldisplay'
        'socketreceive'
        'socketsend'
        'soundfiler'
        'source'
        'stepper'
        'textbox'
        'texteditor'
      ]
      deprecatedWidgetTypes = [
        'directorylist'
        'fftdisplay'
        'hostrecording'
        'listbox'
        'multitab'
        'patmatrix'
        'popupmenu'
        'pvsview'
        'recordbutton'
        'snapshot'
        'sourcebutton'
        'table'
        'transport'
      ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (widgetTypes.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe widgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetTypes[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'keyword.widget-type.cabbage-gui.csound-document'
        ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (deprecatedWidgetTypes.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe deprecatedWidgetTypes.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetTypes[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'invalid.deprecated.cabbage-gui.csound-document'
        ]

    it 'tokenizes Cabbage widget identifiers', ->
      # https://github.com/rorywalsh/cabaiste/search?q=CabbageIdentifierStrings+path%3ASource+filename%3ACabbageIds.h
      widgetIdentifiers = [
        'active'
        'address'
        'align'
        'alpha'
        'amprange'
        'arrowbackgroundcolour'
        'arrowcolour'
        'backgroundcolor'
        'backgroundcolour'
        'ballcolour'
        'blacknotecolour'
        'bounds'
        'caption'
        'channel'
        'channelarray'
        'channels'
        'channeltype'
        'color:0'
        'color:1'
        'color'
        'colour:0'
        'colour:1'
        'colour'
        'corners'
        'displaytype'
        'file'
        'fill'
        'fontcolor:0'
        'fontcolor:1'
        'fontcolor'
        'fontcolour:0'
        'fontcolour:1'
        'fontcolour'
        'fontstyle'
        'guirefresh'
        'highlightcolour'
        'identchannel'
        'imgdebug'
        'imgfile'
        'imgpath'
        'items'
        'keywidth'
        'kind'
        'latched'
        'linethickness'
        'max'
        'menucolor'
        'middlec'
        'min'
        'mode'
        'noteseparatorcolour'
        'numberofsteps'
        'outlinecolor'
        'outlinecolour'
        'outlinethickness'
        'plant'
        'pluginid'
        'populate'
        'popup'
        'popuptext'
        'pos'
        'radiogroup'
        'range'
        'rangex'
        'rangey'
        'refreshfiles'
        'rescale'
        'rotate'
        'samplerange'
        'scrubberposition'
        'shape'
        'show'
        'signalvariable'
        'size'
        'sliderincr'
        'tablebackgroundcolour'
        'tablecolor'
        'tablecolour'
        'tablegridcolor'
        'tablegridcolour'
        'tablenumber'
        'tablenumbers'
        'text'
       #'textbox'
        'textcolor'
        'textcolour'
        'titlebarcolour'
        'trackercolor'
        'trackercolour'
        'trackerthickness'
        'updaterate'
        'value'
        'valuetextbox'
        'velocity'
        'visible'
        'whitenotecolour'
        'widgetarray'
        'wrap'
        'zoom'
      ]
      deprecatedWidgetIdentifiers = [
        'bold'
        'ffttablenumber'
        'gradient'
        'logger'
        'scalex'
        'scaley'
        'scroll'
        'scrollbars'
        'tablebackgroundcolor'
      ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (widgetIdentifiers.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe widgetIdentifiers.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: widgetIdentifiers[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'support.function.widget-identifier.cabbage-gui.csound-document'
        ]
      lines = grammar.tokenizeLines(
        '<Cabbage>\n' +
        (deprecatedWidgetIdentifiers.join '\n') +
        '</Cabbage>\n'
      )
      expect(lines.length - 2).toBe deprecatedWidgetIdentifiers.length
      for i in [1...lines.length - 1]
        expect(lines[i][0]).toEqual value: deprecatedWidgetIdentifiers[i - 1], scopes: [
          'source.csound-document'
          'meta.cabbage-gui.csound-document'
          'invalid.deprecated.cabbage-gui.csound-document'
        ]
