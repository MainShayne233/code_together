import React, {Component} from 'react'
import { createCoderoom }  from '../utils/api'
import { Link } from 'react-router'

export default class NewCoderoomForm extends Component {

  constructor(props) {
    super(props)
    this.state = {
      privateChecked: false,
      errors: [],
    }
  }

  componentDidMount() {
    $('.checkbox')
      .checkbox({
        onChange: () => this.state.privateChecked = !this.state.privateChecked
      })
      .checkbox('check')

    $('.ui.small.modal')
      .modal({
        onApprove: () => false,
      })
  }

  componentWillUnmount() {
    $('.ui.small.modal').remove()
  }

  handleSubmit(event) {
    event.preventDefault()
    const {name, language} = this.refs
    const isPrivate = this.state.privateChecked
    const params = {
      name:     name.value,
      language: language.value,
      private:  isPrivate
    }
    createCoderoom(params).then(response => {
      const { data } = response
      if (data.error) {
        this.handleError(data.error)
      } else {
        this.hide()
        const route = `/coderooms/${isPrivate ? 'private' : 'public'}/${data.name}`
        this.props.browserHistory.replace(route)
      }
    })
  }

  handleError(errors) {
    this.setState({
      errors: errors
    }, () => this.refs.name.focus())
  }

  handleCheckboxChange() {
    this.setState({
      privateChecked: !this.state.privateChecked
    }, () => $('.checkbox').checkbox('toggle'))
  }

  renderErrors() {
    if (this.state.errors.length === 0) return null
    const errors =  this.state.errors.map((error, index) => {
      return <p key={index}>{`- ${error}`}</p>
    })
    return (
      <div className='ui segment'>
        {errors}
      </div>
    )
  }

  hide() {
    $('.ui.small.modal')
      .modal('hide')
  }

  show() {
    $('.ui.small.modal')
      .modal('show')
  }

  render() {
    return (
      <div className="ui small modal">
        <div className="header">
          Create coderoom
        </div>
        <div className="content">
          {this.renderErrors()}
          <form onSubmit={this.handleSubmit.bind(this)} className="ui small form">
            <div className="three fields">
              <div style={{paddingTop: 18}} className="field">
                <input ref='name' placeholder="Coderoom name" type="text"/>
              </div>
              <div style={{paddingTop: 18}} className="field">
                <select ref='language' className='ui fluid dropdown'>
                  <option value=''>Language</option>
                  <option value='ruby'>Ruby</option>
                </select>
              </div>
              <div className='field'>
                <div style={{marginTop: 25}} className="ui checkbox">
                  <input
                    onChange={this.handleCheckboxChange.bind(this)}
                    value={this.state.privateChecked}
                    type="checkbox"
                  />
                  <label>Private</label>
                </div>
              </div>
            </div>
          </form>
        </div>
        <div className="actions">
          <div className="ui black deny button">
            Cancel
          </div>
          <div onClick={this.handleSubmit.bind(this)} className="ui positive right button">
            Create
          </div>
        </div>
      </div>
    )
  }
}

function onApprove() {
  return false
}
