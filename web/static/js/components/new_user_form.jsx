import React, {Component} from 'react'
import { createNewUser }  from '../utils/api'

export default class NewUserForm extends Component {


  handleSubmit(event) {
    event.preventDefault()
    const username = this.refs.username.value
    createNewUser(username).then(response => {
      if (response.error) {
        this.handleError(response.error)
      } else {
        this.props.handleNewUser()
      }
    })
  }

  handleError(error) {
    console.log(error)
  }

  render() {
    return (
      <form style={{paddingTop: 200}} className="ui form"
        onSubmit={this.handleSubmit.bind(this)}
        >
        <div className="three fields">
          <div className="field "></div>
          <div className="field ui raised segment">
            <h2 style={{textAlign: 'center'}}>Choose a username</h2>
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
    )
  }
}
