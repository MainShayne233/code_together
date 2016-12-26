import React, { Component } from 'react'
import { Router, Route, browserHistory } from 'react-router'
import Coderoom from './coderoom.jsx'
import Lobby from './lobby.jsx'
import NewUserForm from './new_user_form.jsx'
import NewCoderoomForm from './new_coderoom_form.jsx'
import { getCurrentUser }    from '../utils/api.js'

export default class Session extends Component {

  componentWillMount() {
    this.fetchCurrentUser()
  }

  fetchCurrentUser() {
    getCurrentUser().then(username => {
      this.setState({
        currentUser: username,
      })
    })
  }

  handleNewUser() {
    this.fetchCurrentUser()
  }

  renderLoading() {
    return (
      <div></div>
    )
  }

  renderNewUserForm() {
    return (
      <NewUserForm
        handleNewUser={this.handleNewUser.bind(this)}
      />
    )
  }

  renderIndex() {
    return (
      <Router history={browserHistory}>
        <Route
          path='/coderooms/new'
          component={NewCoderoomForm}
          browserHistory={browserHistory}
        />
        <Route
          path='/coderooms/:access/:name'
          component={Coderoom}
          browserHistory={browserHistory}
        />
        <Route
          path='/'
          component={Lobby}
          currentUser={this.state.currentUser}
          browserHistory={browserHistory}
        />
      </Router>
    )
  }

  render() {
    if (!this.state) {
      return this.renderLoading()
    } else if (this.state.currentUser) {
      return this.renderIndex()
    } else {
      return this.renderNewUserForm()
    }
  }
}
