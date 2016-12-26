import React, { Component } from 'react'
import { Socket } from "phoenix"
import CodeEditor from './code_editor.jsx'
import CodeOutput from './code_output.jsx'
import { getCoderoom, getCurrentUser } from '../utils/api'
import { default as swal } from 'sweetalert2'
import { Link } from 'react-router'
import Header from './header.jsx'

export default class Coderoom extends Component {

  constructor(props) {
    super(props)
    this.state = {
      channel: null,
    }
    this.configure()
  }

  configure() {
    const {access, name} = this.props.params
    getCoderoom({
      private: access === 'private',
      name:    name,
    }).then(response => {
      this.setState(response.data, () => this.configureSocketAndChannels())
    })
  }

  configureSocketAndChannels() {
    getCurrentUser().then(username => {
      this.state.currentUser = username
      let socket = new Socket("/socket", {params: {token: window.userToken}})
      socket.connect()
      let channel = socket.channel("code_room:connect", {code_room_id: this.state.id})
      channel.join()
        .receive("ok",    resp => { console.log("Joined successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })
      channel.push("code_room:prepare", {username: username})
      channel.on("code_room:not_ready", data => {
        if (!swal.isVisible()) {
          swal({
            text: data.message,
            confirmButtonText: 'Cool',
            showLoaderOnConfirm: true,
          })
          swal.showLoading()
        }
      })

      channel.on("code_room:ready", data => {
        swal.close()
      })
      this.setState({
        channel: channel,
      })
    })
  }

  render() {
    if (this.state.channel) {
      return (
        <div>
          <Header/>
          <h2 style={{textAlign: 'center', marginTop: -25}}>{this.state.name}</h2>
          <div className='ui segment' style={{display: 'flex'}}>
            <div style={{flex: 1}}>
              <CodeEditor
                ref='codeEditor'
                initialCode={this.state.code}
                channel={this.state.channel}
                currentUser={this.state.currentUser}
              />
            </div>
            <div style={{flex: 1}}>
              <CodeOutput
                ref='codeOutput'
                initialOutput={this.state.output}
                channel={this.state.channel}
                currentUser={this.state.currentUser}
              />
            </div>
          </div>
        </div>
      )
    } else {
      return (
        <div>
        </div>
      )
    }
  }
}
