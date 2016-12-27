import React, { Component } from 'react'
import NewCoderoomForm      from './new_coderoom_form.jsx'
import { getPublicCoderooms } from '../utils/api'
import { Link } from 'react-router'
import Header from './header.jsx'
import { Modal } from 'semantic-ui-react'

export default class Lobby extends Component {

  constructor(props) {
    super(props)
    this.state = {
      publicCodeRooms: []
    }
    getPublicCoderooms().then(publicCodeRooms => {
      this.setState({
        publicCodeRooms: publicCodeRooms
      })
    })
  }

  componentDidMount() {
    $('.ui.dropdown').dropdown()
  }

  renderCoderoomCards() {
    return this.state.publicCodeRooms.map((room, index) => {
      return (
        <div key={index} className='row'>
          <div className='four wide column'>
            <div  className="item">
              <img className="ui left floated avatar image" src={`/images/${room.language}.png`}/>
              <div className="content">
                <div className="header"><h3><Link to={`/coderooms/public/${room.name}`}>{room.name}</Link></h3></div>
                {`${room.language} - ${room.current_users.length} busy busy coding`}
              </div>
            </div>
          </div>
        </div>
      )
    })
  }

  renderPublicCoderooms() {
    return (
      <div
        style={{flex: 0.75}}
        className="ui one column centered internally celled grid"
        >
        {this.renderCoderoomCards()}
      </div>
    )
  }

  handleCoderoomFormShow() {
    this.refs.newCoderoomForm.show()
  }

  render() {
    return (
      <div style={{textAlign: 'center'}}>
        <Header/>
        <div style={{marginTop: -20}}>
          <h1>Join a coderoom</h1>
          <div className='ui form' style={{display: 'flex', justifyContent: 'center'}}>
            <div style={{width: 175}} className="ui field">
              <input ref='name' placeholder="Search..." type="text"/>
            </div>
            <div style={{width: 175}} className="field">
              <select ref='language' className='ui fluid dropdown'>
                <option value='all'>All Languages</option>
                <option value='ruby'>Ruby</option>
              </select>
            </div>
          </div>
          <div style={{height: 500, overflowY: 'auto'}} className='ui segment'>
            {this.renderPublicCoderooms()}
          </div>
          <input
            onClick={this.handleCoderoomFormShow.bind(this)}
            className='ui positive button'
            type='button'
            value='Create New Coderoom'
          />
        <NewCoderoomForm ref='newCoderoomForm' browserHistory={this.props.route.browserHistory}/>
        </div>
      </div>
    )
  }
}
