import fs from 'fs'
import { execSync } from 'child_process'

export default function(code) {
  const return_code = `begin\n` +
                      `  return_val = eval %Q{\n${code}\n}\n` +
                      `  print "=> #{return_val || 'nil'}"\n` +
                      `rescue Exception => e\n` +
                      `  print e\n` +
                      `end`
  fs.writeFileSync('ruby_for_return.rb', return_code, 'utf8')
  const return_result = execSync('ruby ruby_for_return.rb', {encoding: 'utf8'})
  execSync('rm ruby_for_return.rb')
  return return_result
}
