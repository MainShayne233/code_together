import React, { Component } from 'react'
import CodeMirror from 'codemirror'

export default class CodeEditor extends Component {

  static defaultProps = {
    code: ''
  }

  componentDidMount() {
    this.configureCodeMirror()
    this.configureChannel()
    window.addEventListener('resize', () => {
      this.state.codeMirror.setSize('99%', this.props.height)
    })
  }

  configureCodeMirror() {
    let codeMirror = CodeMirror.fromTextArea(this.refs.codeMirror, {
      mode:        'text/x-ruby',
      lineNumbers: true,
      lineWrapping: true,
      indentUnit:  2,
      tabSize:     2,
      theme: 'material',
    })
    codeMirror.setValue(this.props.initialCode || '')
    codeMirror.setSize('99%', this.props.height)
    this.state = {
      codeMirror: codeMirror
    }
    if (this.props.cursorPosition) {
      code_mirror.setCursor(this.props.cursorPosition)
    }
  }

  handleCodeUpdate(code) {
    const {channel, currentUser} = this.props
    channel.push('coderoom:new_code', {
      code: code,
      username: currentUser,
    })
  }

  handleRunCode() {
    const {channel} = this.props
    const {codeMirror} = this.state
    const code = codeMirror.getValue()
    channel.push('coderoom:run', {
      code: code,
    })
  }

  currentCode() {
    return this.state.codeMirror.getValue()
  }

  currentCursorPosition() {
    return this.state.codeMirror.getCursor()
  }

  configureChannel() {
    const {channel, currentUser} = this.props
    const {codeMirror} = this.state
    codeMirror.on('keydown', (mirror, event) => {
      if (event.shiftKey && event.code === 'Enter') {
        this.handleRunCode()
        event.preventDefault()
      }
    })
    codeMirror.on('keyup', () => {
      const code = codeMirror.getValue()
      channel.push('coderoom:new_code', {
        code: code,
        username: currentUser,
      })
    })
    channel.on("coderoom:code_update", data => {
      const {code, username} = data
      if (username !== this.props.currentUser) {
        const code = data.code
        const cursorPosition = codeMirror.getCursor()
        codeMirror.setValue(code)
        codeMirror.setCursor(cursorPosition)
      }
    })
  }


  render() {
    return (
      <div
        >
        <textarea
          ref='codeMirror'
          >
        </textarea>
      </div>
    )
  }
}
