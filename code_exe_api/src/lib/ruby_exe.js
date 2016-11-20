import fs from 'fs'
import { execSync } from 'child_process'

export default function(code) {
  const return_code = `return_val = eval %Q{\n${code}\n}; print "=> #{return_val || 'nil'}"`
  fs.writeFileSync('ruby_for_return.rb', return_code, 'utf8')
  const return_result = execSync('ruby ruby_for_return.rb', {encoding: 'utf8'})
  execSync('rm ruby_for_return.rb')
  return return_result
}
