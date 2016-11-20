'use strict';

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _package = require('../../package.json');

var _express = require('express');

var _facets = require('./facets');

var _facets2 = _interopRequireDefault(_facets);

var _processOrder = require('../lib/processOrder');

var _processOrder2 = _interopRequireDefault(_processOrder);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.default = function (_ref) {
	var config = _ref.config,
	    db = _ref.db;

	var api = (0, _express.Router)();

	// mount the facets resource
	api.use('/facets', (0, _facets2.default)({ config: config, db: db }));

	// perhaps expose some API metadata at the root
	api.get('/', function (req, res) {
		res.json({ hey: "man" });
	});

	api.get('/cost', function (req, res) {
		var requestedOrder = req.body.order;
		var order = (0, _processOrder2.default)(requestedOrder);
		if (order.error) {
			res.status(400).send(order.error);
		} else {
			res.json({
				cost: order.totalCost
			});
		}
	});

	return api;
};
//# sourceMappingURL=index.js.map