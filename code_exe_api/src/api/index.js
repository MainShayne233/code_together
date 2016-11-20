import { version } from '../../package.json'
import { Router } from 'express'

import rubyExe from '../lib/ruby_exe'

export default ({ config, db }) => {
	let api = Router();

	api.get('/ruby/run', (req, res) => {
		const code = req.query.code
		const ruby_result = rubyExe(code)
		res.json(ruby_result)
	})

	return api
}
