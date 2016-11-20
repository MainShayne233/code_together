'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = costsFor;

var _quadExpressCosts = require('./quadExpressCosts');

var _quadExpressCosts2 = _interopRequireDefault(_quadExpressCosts);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function costsFor(args) {
  var order = args.order;
  var vendor = args.vendor;
  var orderCost = {
    'quad express': (0, _quadExpressCosts2.default)(args)
  }[(vendor || '').toLowerCase() || 'quad express'];

  return orderCost;
}
//# sourceMappingURL=costs.js.map