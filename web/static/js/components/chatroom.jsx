import React, {Component} from 'react'

export default class Chatroom extends Component {

  componentDidMount() {
    this.refs.chat.scrollTop = this.refs.chat.scrollHeight
  }

  componentDidUpdate() {
    this.refs.chat.scrollTop = this.refs.chat.scrollHeight
  }

  handleSubmit(event) {
    event.preventDefault()
    let {chatInput} = this.refs
    const newMsg = chatInput.value
    if (newMsg.trim() !== '') {
      const newChat = `${this.props.currentUser}:${newMsg}`
      this.props.channel.push('coderoom:new_chat', {new_chat: newChat})
      chatInput.value = ''
      chatInput.focus()
    }
  }

  handleKeyUp(event) {
    if (event.key === 'Enter') {
      if (event.shiftKey) {
        event.preventDefault()
      } else {
        this.handleSubmit(event)
      }
    }
  }

  textAreaRows() {
    return 1 + parseInt(Number(this.props.height / 500).toFixed(0))
  }

  renderChat() {
    return this.props.chat.split("\n").map((msg, index) => {
      const splitPoint = msg.indexOf(':')
      if (splitPoint === -1) return null
      const username = msg.slice(0, splitPoint)
      const message  = msg.slice(splitPoint + 1, msg.length)
      const backgroundColor = this.props.currentUser === username ? '#e6e6e6' : 'white'
      return (
        <div key={index} style={{display: 'flex', backgroundColor: backgroundColor, marginBottom: 5}} className='ui segment'>
          <div style={{marginRight: 5, fontWeight: 'bold'}}>{username + ':'} </div>
          <div style={{flex: 1, wordBreak: 'break-all'}} >{message}</div>
        </div>
      )
    })
  }

  render() {
    return (
      <div
        style={{height: 100 + this.props.height * 0.61}} ref='chatroomContainer'
        className='ui raised segment'
        >
        <h3>Chat</h3>
        <div
          ref='chat'
          className='ui segment'
          style={{height: this.props.height * 0.55, overflowY: 'auto'}}
          >
          {this.renderChat()}
        </div>
        <form
          className='ui form'
          onSubmit={this.handleSubmit.bind(this)}
          >
          <div className='field'>
            <textarea
              placeholder="Type message here and press enter to send"
              onKeyDown={this.handleKeyUp.bind(this)}
              ref='chatInput'
              rows={this.textAreaRows()}
              >
            </textarea>
          </div>
        </form>
      </div>
    )
  }
}
