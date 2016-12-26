import React, { Component } from 'react'
import CodeMirror from 'codemirror'

export default class CodeEditor extends Component {

  static defaultProps = {
    code: ''
  }

  componentDidMount() {
    this.configureCodeMirror()
    this.configureChannel()
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
    codeMirror.setSize('99%', 600)
    this.state = {
      codeMirror: codeMirror
    }
    if (this.props.cursorPosition) {
      code_mirror.setCursor(this.props.cursorPosition)
    }
  }

  handleCodeUpdate(code) {
    const {channel, currentUser} = this.props
    channel.push('code_room:new_code', {
      code: code,
      username: currentUser,
    })
  }

  handleRunCode() {
    const {channel} = this.props
    const {codeMirror} = this.state
    const code = codeMirror.getValue()
    channel.push('code_room:run', {
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
    codeMirror.on('keydown', () => {
      if (event.shiftKey && event.code === 'Enter') {
        this.handleRunCode()
        event.preventDefault()
      }
    })
    codeMirror.on('keyup', () => {
      const code = codeMirror.getValue()
      channel.push('code_room:new_code', {
        code: code,
        username: currentUser,
      })
    })
    channel.on("code_room:code_update", data => {
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
        <button
          className='ui button'
          ref='runCodeButton'
          onClick={this.handleRunCode.bind(this)}
          >
          Run Code
        </button>
      </div>
    )
  }
}
