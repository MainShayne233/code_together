import "phoenix_html"
import {
  socket,
  channel,
} from "./socket"
import CodeMirror from 'codemirror'
require('codemirror/mode/ruby/ruby')

const code_text_area = document.getElementById('ruby-code-mirror')
const output_text_area = document.getElementById('ruby-output')
const token = document.getElementById("token").value

let ruby_code_mirror = CodeMirror.fromTextArea(code_text_area, {
  mode:        "text/x-ruby",
  lineNumbers: true,
  indentUnit:  4,
  tabSize:     4,
})


let ruby_output_mirror = CodeMirror.fromTextArea(output_text_area, {
  mode:        "text/x-ruby",
  lineNumbers: true,
  indentUnit:  4,
  tabSize:     4,
  readOnly:    true,
})



ruby_code_mirror.setValue("def method\n  'cool'\nend")

const run_code_button = document.getElementById('run-ruby-code')

run_code_button.addEventListener('click', (event) => {
  const code = ruby_code_mirror.getValue()
  channel.push('code_room:run', {code: code, token: token})
  console.log(code)
})



channel.on("code_room:output_update", data => {
  const output = data.output
  ruby_output_mirror.setValue(output)
})
