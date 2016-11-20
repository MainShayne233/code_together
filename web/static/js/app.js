import "phoenix_html"
import socket from "./socket"
import CodeMirror from 'codemirror'
require('codemirror/mode/ruby/ruby')

const code_text_area = document.getElementById('ruby-code-mirror')

let ruby_code_mirror = CodeMirror.fromTextArea(code_text_area, {
  mode:        "text/x-ruby",
  lineNumbers: true,
  indentUnit:  2,
  tabSize:     2,
})

const output_text_area = document.getElementById('ruby-output')

let ruby_output_mirror = CodeMirror.fromTextArea(output_text_area, {
  mode:        "text/x-ruby",
  lineNumbers: true,
  indentUnit:  2,
  tabSize:     2,
  readOnly:    true,
})

ruby_code_mirror.setValue("def method\n  'cool'\nend")

const run_code_button = document.getElementById('ruby-code-mirror')
