import React, {Component} from 'react'
import {Link} from 'react-router'

export default class Header extends Component {

  render() {
    return (
      <div style={{
          display: 'flex',
          flexFlow: 'flex-start',
          marginTop: -5,
          fontSize: '20px',
          textAlign: 'center',
        }}>
        <Link to='/'>
          <i style={{
              marginTop: 15,
              marginLeft: 10,
              color: 'black',
            }} className="circular users icon">
          </i>
        </Link>
        <h3><Link style={{
            color: 'black'
          }} to='/'>Code Together</Link></h3>
      </div>
    )
  }
}
