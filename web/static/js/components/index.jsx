import React, { Component } from 'react'
import NewCoderoomForm      from './new_coderoom_form.jsx'

export default class Index extends Component {

  handleBrowseCoderoomsClick() {

  }

  handleCreateCoderoomClick() {
    this.props.route.browserHistory.push("/coderooms/new")
  }

  render() {
    const { currentUser } = this.props.route
    return (
      <div style={{display: 'flex', marginTop: 200,}}>
        <div style={{flex: 0.5}}></div>
        <div style={{flex: 1, textAlign: 'center'}} className='ui raised segment'>
          <div style={{width: 500}} className="ui buttons">
            <button
              className="ui button"
              onClick={this.handleBrowseCoderoomsClick.bind(this)}
              >
              Browse coderooms
            </button>
            <div className="or" data-text="or"></div>
            <button
              className="ui positive button"
              onClick={this.handleCreateCoderoomClick.bind(this)}
              >
              Create a coderoom
            </button>
          </div>
        </div>
        <div style={{flex: 0.5}}></div>
      </div>
    )
  }
}
