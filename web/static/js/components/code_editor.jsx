import React, { Component } from 'react'
// import CodeMirror from 'codemirror'
import CodeMirror from './Codemirror'

const maxCharacterCount = 100000

export default class CodeEditor extends Component {

  // Lifecyle Functions

  constructor(props) {
    super(props)
    this.configureChannel()
    this.state = {
      code: props.initialCode || ''
    }
  }

  componentDidMount() {
    const { mirror } = this.refs
    const codeMirror = mirror.getCodeMirror()
    codeMirror.setSize(null, this.props.height * 0.7)
  }

  // Config Functions

  configureChannel() {
    const {channel, currentUser} = this.props
    channel.on("coderoom:code_update", data => {
      if (data.username !== currentUser) {
        const { mirror } = this.refs
        this.setState({
          code: data.code
        })
      }
    })
  }

  // Handler Functions

  handleChange(code, change) {
    const {channel, currentUser} = this.props
    this.setState({
      code: code,
    }, () => {
      channel.push('coderoom:new_code', {
        code:     code,
        username: currentUser,
      })
    })
  }

  handleKeyDown(codeMirror, event) {
    if (event.keyCode === 13 && event.shiftKey) {
      event.preventDefault()
      this.handleRunCode()
    }
  }

  handleRunCode() {
    const {channel} = this.props
    const {code}    = this.state
    channel.push('coderoom:run', {
      code: code,
    })
  }

  // Render Helpers

  codeMirrorOptions() {
    return {
      theme:        'material',
      lineNumbers:  true,
      lineWrapping: true,
      autofocus:    true,
    }
  }

  // Render Functions

  render() {
    return (
      <div
        style={{maxWidth: this.props.width / 2.5}}
        >
        <CodeMirror
          ref='mirror'
          value={this.state.code}
          mode='ruby'
          options={this.codeMirrorOptions()}
          onChange={this.handleChange.bind(this)}
          onKeyDown={this.handleKeyDown.bind(this)}
          preserveCursorPosition={true}
        />
      </div>
    )
  }
}
