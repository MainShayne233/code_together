import React, { Component } from 'react'
import CodeMirror from './Codemirror'

export default class CodeOutput extends Component {

  // Lifecyle Functions

  constructor(props) {
    super(props)
    this.configureChannel()
    this.state = {
      output: props.initialOutput || ''
    }
  }

  componentDidMount() {
    this.refs.mirror.setSize(null, this.props.height * 0.7)
  }

  // Config Functions

  configureChannel() {
    const {channel, currentUser} = this.props
    channel.on("coderoom:output_update", data => {
      if (data.username !== currentUser) {
        const { mirror } = this.refs
        this.setState({
          output: data.output
        })
      }
    })
  }

  // Render Helpers

  codeMirrorOptions() {
    return {
      theme:        'material',
      lineNumbers:  true,
      lineWrapping: true,
      readOnly:     true,
      mode: 'shell'
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
          value={this.state.output}
          options={this.codeMirrorOptions()}
          anchorBottom={true}
        />
      </div>
    )
  }
}
