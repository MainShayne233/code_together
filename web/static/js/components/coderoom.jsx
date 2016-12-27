import React, { Component } from 'react'
import { Socket } from "phoenix"
import CodeEditor from './code_editor.jsx'
import CodeOutput from './code_output.jsx'
import { getCoderoom, getCurrentUser, startCoderoom } from '../utils/api'
import { default as swal } from 'sweetalert2'
import { Link } from 'react-router'
import Header from './header.jsx'
import Chatroom from './chatroom.jsx'

export default class Coderoom extends Component {

  constructor(props) {
    super(props)
    this.state = {
      channel: null,
      height: window.innerHeight * 0.8,
      showMessage: true,
    }
    window.addEventListener('resize', () => {
      this.setState({
        height: window.innerHeight * 0.8,
      })
    })
    this.configure()
  }

  configure() {
    const {access, name} = this.props.params
    startCoderoom({
      private: access === 'private',
      name:    name,
    })
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
      channel.on("code_room:update_users", data => {
        this.setState({
          current_users: data.current_users
        })
      })
      channel.on("code_room:chat_update", data => {
        this.setState({
          chat: data.chat
        })
      })
      this.setState({
        channel: channel,
      })
    })
  }

  handleCloseMessage() {
    this.setState({
      showMessage: false
    })
  }

  renderMessage() {
    if (this.state.showMessage == false) return null
    return (
      <div style={{width: 500}} className="ui message">
        <i onClick={this.handleCloseMessage.bind(this)} className="close icon"></i>
        <div className="header">
          {`Welcome ${this.state.currentUser}!`}
        </div>
        <ul className="list">
          <li
            style={{fontFamily: "Lato,'Helvetica Neue',Arial,Helvetica,sans-serif;"}}
            >
            Type your code into the field below, and type Shift + Enter to run it
          </li>
        </ul>
      </div>
    )
  }

  render() {
    if (this.state.channel) {
      return (
        <div>
          <Header/>
          <h2 style={{textAlign: 'center', marginTop: -25}}>{this.state.name}</h2>
          <div className='ui raised segment'>
            {this.renderMessage()}
            <div  style={{display: 'flex'}}>
              <div style={{flex: 0.75}}>
                <CodeEditor
                  ref='codeEditor'
                  initialCode={this.state.code}
                  channel={this.state.channel}
                  currentUser={this.state.currentUser}
                  height={this.state.height}
                />
              </div>
              <div style={{flex: 0.6}}>
                <CodeOutput
                  ref='codeOutput'
                  initialOutput={this.state.output}
                  channel={this.state.channel}
                  currentUser={this.state.currentUser}
                  height={this.state.height}
                />
              </div>
              <div style={{width: '25%'}}>
                <Chatroom
                  chat={this.state.chat}
                  channel={this.state.channel}
                  currentUser={this.state.currentUser}
                  height={this.state.height}
                />
              </div>
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
