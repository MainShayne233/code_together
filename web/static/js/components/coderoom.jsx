import React, { Component } from 'react'
import { Socket } from "phoenix"
import { getCoderoom } from '../utils/api'

export default class Coderoom extends Component {

  constructor(props) {
    super(props)
    this.state = {
      coderoom: null
    }
    this.configure()
  }

  configure() {
    const {access, name} = this.props.params
    getCoderoom({
      private: access === 'private',
      name:    name,
    }).then(response => {
      this.setState({
        coderoom: response.data
      }, () => this.configureSocketAndChannels())
    })
  }

  configureSocketAndChannels() {
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()
    let channel = socket.channel("code_room:connect", {code_room_id: this.state.coderoom.id})
    channel.join()
      .receive("ok",    resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }


  render() {
    return (
      <div>hi</div>
    )
  }
}
