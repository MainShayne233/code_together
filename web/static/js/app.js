require("codemirror/lib/codemirror.css")
require('codemirror/mode/ruby/ruby')
require("sweetalert2/dist/sweetalert2.css")
require("codemirror/theme/material.css")
require("semantic-ui/dist/semantic.min.js")
require("semantic-ui/dist/semantic.min.css")
import 'semantic-ui-react'
import                 'phoenix_html'
import React      from 'react'
import { render } from 'react-dom'
import Session    from './components/session.jsx'

render((
  <Session/>
), document.getElementById('app'))


function hasUsername() {
  return true
}
