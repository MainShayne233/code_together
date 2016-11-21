import "phoenix_html"
import {
  socket,
  channel,
} from "./socket"
import CodeMirror from 'codemirror'

const language         = document.getElementById('language').value
const token            = document.getElementById("token").value
const code_text_area   = document.getElementById('code-mirror')
const output_text_area = document.getElementById('output')
const run_code_button  = document.getElementById('run-code')

const language_specific_stuff = {
  ruby: {
    mode_path: 'codemirror/mode/ruby/ruby',
    mode_name: 'text/x-ruby',
    default_code: "class String\n  def palindrome?\n    self == self.reverse\n  end\nend\n\n'racecar'.palindrome?"
  }
}[language.toLowerCase()]

console.log(language, language_specific_stuff)

const mode_path = language_specific_stuff.mode_path
const mode_name = language_specific_stuff.mode_name
const default_code = language_specific_stuff.default_code

require(mode_path)

let code_mirror = CodeMirror.fromTextArea(code_text_area, {
  mode:        mode_name,
  lineNumbers: true,
  indentUnit:  4,
  tabSize:     4,
})

let output_mirror = CodeMirror.fromTextArea(output_text_area, {
  mode:        mode_name,
  lineNumbers: true,
  indentUnit:  4,
  tabSize:     4,
  readOnly:    true,
})

code_mirror.setValue(default_code)

run_code_button.addEventListener('click', (event) => {
  const code = code_mirror.getValue()
  channel.push('code_room:run', {code: code, token: token})
  console.log(code)
})

channel.on("code_room:output_update", data => {
  const output = data.output
  output_mirror.setValue(output)
})
