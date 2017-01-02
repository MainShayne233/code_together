import React, { Component } from 'react'
import CodeMirror from 'codemirror'

export default class CodeOutput extends Component {

  componentDidMount() {
    this.configureCodeMirror()
    this.configureChannel()
    window.addEventListener('resize', () => {
      this.state.codeMirror.setSize('99%', this.props.height)
    })
  }

  configureCodeMirror() {
    let codeMirror = CodeMirror.fromTextArea(this.refs.codeMirror, {
      lineNumbers: true,
      lineWrapping: true,
      indentUnit:  4,
      tabSize:     4,
      readOnly:    true,
      theme: 'material',
      mode: '',
    })
    codeMirror.setValue(this.props.initialOutput || '')
    codeMirror.setSize('99%', this.props.height)
    codeMirror.scrollTo(null, Infinity)
    this.state = {
      codeMirror: codeMirror
    }
  }

  configureChannel() {
    const {channel} = this.props
    const {codeMirror} = this.state
    channel.on("coderoom:output_update", data => {
      const {output} = data
      codeMirror.setValue(output)
      codeMirror.scrollTo(null, Infinity)
    })
  }


  render() {
    return (
      <div>
        <textarea
          ref='codeMirror'
          >
        </textarea>
      </div>
    )
  }
}
