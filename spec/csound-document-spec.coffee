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
      # https://github.com/rorywalsh/cabbage/search?q=GUICtrlsArray+path%3ASource+filename%3ACabbageGUIClass.h
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

      # https://github.com/rorywalsh/cabbage/search?q=GUILayoutCtrlsArray+path%3ASource+filename%3ACabbageGUIClass.h
      widgetTypes = [
        'csoundoutput'
       #'directorylist'
        'filebutton'
        'form'
        'gentable'
        'groupbox'
       #'hostbpm'
       #'hostplaying'
       #'hostppqpos'
       #'hostrecording'
       #'hosttime'
        'image'
        'infobutton'
        'keyboard'
        'label'
       #'line'
       #'listbox'
       #'loadbutton'
       #'multitab'
       #'patmatrix'
       #'popupmenu'
       #'pvsview'
       #'recordbutton'
       #'snapshot'
       #'socketreceive'
       #'socketsend'
        'soundfiler'
       #'source'
       #'sourcebutton'
       #'stepper'
        'textbox'
        'texteditor'
       #'transport'
      ]
      deprecatedWidgetTypes = [
        'fftdisplay'
        'table'
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
      # https://github.com/rorywalsh/cabbage/search?q=IdentArray+path%3ASource+filename%3ACabbageGUIClass.h
      widgetIdentifiers = [
        'active'
        'address'
        'align'
        'alpha'
        'amprange'
        'bold'
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
        'ffttablenumber'
        'file'
        'fill'
        'fontcolor:0'
        'fontcolor:1'
        'fontcolor'
        'fontcolour:0'
        'fontcolour:1'
        'fontcolour'
        'fontstyle'
        'gradient'
        'guirefresh'
        'highlightcolour'
        'identchannel'
        'items'
        'kind'
        'latched'
        'linethickness'
        'logger'
        'max'
        'middlec'
        'min'
        'mode'
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
        'rescale'
        'rotate'
        'samplerange'
        'scalex'
        'scaley'
        'scroll'
        'scrollbars'
        'scrubberposition'
        'shape'
        'show'
        'size'
        'sliderincr'
        'stepbpm'
        'svgdebug'
        'svgfile'
        'svgpath'
        'tablebackgroundcolor'
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
        'trackercolor'
        'trackercolour'
        'trackerthickness'
        'value'
        'velocity'
        'visible'
        'widgetarray'
        'wrap'
        'zoom'
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
