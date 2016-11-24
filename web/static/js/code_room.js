import "phoenix_html"
import CodeMirror from 'codemirror'
import { default as swal } from 'sweetalert2'
import {Socket} from "phoenix"

const username         = document.getElementById('username').value.trim()
const code_room_id     = parseInt(document.getElementById('code-room-id').value.trim())
const code_text_area   = document.getElementById('code-mirror')
const output_text_area = document.getElementById('output')
const run_code_button  = document.getElementById('run-code')

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

let channel = socket.channel("code_room:connect", {code_room_id: code_room_id})

channel.join()
  .receive("ok",    resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.push("code_room:prepare", {})

channel.on("code_room:not_ready", data => {
  if (!swal.isVisible()) {
    swal({
      text: data.message,
      confirmButtonText: 'Cool',
      showLoaderOnConfirm: true,
    })
    swal.showLoading()
  }
})

channel.on("code_room:ready", data => {
  swal.close()
})

const XHR = new XMLHttpRequest()
XHR.onreadystatechange = () => {
  if (XHR.readyState === 4 && XHR.status === 200) {
    const initial_data = JSON.parse(XHR.responseText)
    set_up_code_room(initial_data)
  }
}
XHR.open("GET", `/api/code_rooms/${code_room_id}/initial_data`, true)
XHR.send(null)

function set_up_code_room(initial_data) {
  var mode_path
  var mode_name
  switch(initial_data.language.toLowerCase()) {
    case 'ruby':
          console.log('ruby mode triggered')
          require('codemirror/mode/ruby/ruby')
          mode_name = 'text/x-ruby'
          break
    default:
      console.log('no language to work with')
  }

  let code_mirror = CodeMirror.fromTextArea(code_text_area, {
    mode:        mode_name,
    lineNumbers: true,
    lineWrapping: true,
    indentUnit:  4,
    tabSize:     4,
    theme: 'material',
  })

  let output_mirror = CodeMirror.fromTextArea(output_text_area, {
    lineNumbers: true,
    lineWrapping: true,
    indentUnit:  4,
    tabSize:     4,
    readOnly:    true,
    theme: 'material',
    mode: '',
  })

  code_mirror.setSize('auto', 400)
  output_mirror.setSize('auto', 400)

  code_mirror.setValue(initial_data.code)
  output_mirror.setValue(initial_data.output)

  scroll_to_bottom_of(output_mirror)

  // tell server someone typed some code
  code_mirror.on('keyup', event => {
    const code = code_mirror.getValue()
    channel.push('code_room:new_code', {
      code: code,
      username: username,
    })
  })

  // tell all clients what the new code is
  channel.on("code_room:code_update", data => {
    if (needs_update(data)) {
      const code = data.code
      const cursor_position = code_mirror.getCursor()
      code_mirror.setValue(code)
      code_mirror.setCursor(cursor_position)
    }
  })

  function needs_update(data) {
    return data.username     !== username     &&
           data.code         !== code_mirror.getValue()
  }

  run_code_button.addEventListener('click', (event) => {
    const code = code_mirror.getValue()
    channel.push('code_room:run', {
      code: code,
    })
  })

  channel.on("code_room:output_update", data => {
    const output = data.output
    output_mirror.setValue(output)
    scroll_to_bottom_of(output_mirror)
  })
}

function scroll_to_bottom_of(mirror) {
  mirror.scrollTo(null, Infinity)
}
