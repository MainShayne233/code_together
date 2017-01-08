import React, {Component} from 'react'
import { createNewUser }  from '../utils/api'

export default class NewUserForm extends Component {

  constructor(props) {
    super(props)
    this.state = {
      errors: [],
    }
  }


  handleSubmit(event) {
    event.preventDefault()
    const username = this.refs.username.value
    createNewUser(username).then(response => {
      if (response.data.errors) {
        this.handleErrors(response.data.errors)
      } else {
        this.props.handleNewUser()
      }
    })
  }

  handleErrors(errors) {
    this.setState({
      errors: errors,
    })
  }

  renderErrors() {
    if (this.state.errors.length) {
      const errors = this.state.errors.map((error, index) => {
        return <li key={index}>{error}</li>
      })
      return <ul>{errors}</ul>
    } else {
      return null
    }
  }

  render() {
    return (
      <div>
        <h2 style={{paddingTop: 100}} className="ui center aligned icon header">
          <i className="circular users icon"></i>
          Code Together
        </h2>
        <form style={{paddingTop: 40}} className="ui form"
          onSubmit={this.handleSubmit.bind(this)}
          >
          <div className="three fields">
            <div className="field "></div>
            <div className="field ui raised segment">
              <h2 style={{textAlign: 'center'}}>Choose a username</h2>
              {this.renderErrors()}
              <input
                autoFocus={true}
                ref="username"
                style={{textAlign: 'center'}}
                type="text"
                placeholder='. . .'
              />
            </div><div className="field">
            </div>
          </div>
        </form>
      </div>
    )
  }
}
