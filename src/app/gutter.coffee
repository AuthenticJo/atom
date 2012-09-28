{View, $$, $$$} = require 'space-pen'

$ = require 'jquery'
_ = require 'underscore'

module.exports =
class Gutter extends View
  @content: ->
    @div class: 'gutter', =>
      @div outlet: 'lineNumbers', class: 'line-numbers'

  firstScreenRow: -1
  highestNumberWidth: null

  afterAttach: (onDom) ->
    @editor()?.on 'cursor-move', => @highlightCursorLine()
    @calculateWidth() if onDom

  editor: ->
    @parentView

  lineNumberPadding: ->
    widthTesterElement = $$ -> @div {class: 'line-number'}, ""
    @append(widthTesterElement)
    lineNumberPadding = widthTesterElement.outerWidth()
    widthTesterElement.remove()
    lineNumberPadding

  renderLineNumbers: (startScreenRow, endScreenRow) ->
    @firstScreenRow = startScreenRow
    lastScreenRow = -1
    rows = @editor().bufferRowsForScreenRows(startScreenRow, endScreenRow)

    cursorScreenRow = @editor().getCursorScreenPosition().row
    @lineNumbers[0].innerHTML = $$$ ->
      for row in rows
        rowClass = 'line-number'
        rowValue = null

        if row == lastScreenRow
          rowValue = '•'
        else
          rowValue = row + 1
          rowClass += ' cursor-line-number' if row == cursorScreenRow

        @div {class: rowClass}, rowValue
        lastScreenRow = row

    @calculateWidth()
    @highlightCursorLine()

  calculateWidth: ->
    highestNumberWidth = @editor().getLineCount().toString().length * @editor().charWidth
    if highestNumberWidth != @highestNumberWidth
      @highestNumberWidth = highestNumberWidth
      @lineNumbers.width(highestNumberWidth + @lineNumberPadding())
      @widthChanged?(@outerWidth())

  highlightCursorLine: ->
    cursorScreenRow = @editor().getCursorScreenPosition().row
    screenRowIndex = cursorScreenRow - @firstScreenRow
    @find(".line-number.cursor-line-number").removeClass('cursor-line-number')
    @find(".line-number:eq(#{screenRowIndex})").addClass('cursor-line-number')
