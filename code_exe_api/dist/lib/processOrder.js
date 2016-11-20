'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = processOrder;

var _lodash = require('lodash');

var _lodash2 = _interopRequireDefault(_lodash);

var _sanitizeOrder = require('./sanitizeOrder');

var _sanitizeOrder2 = _interopRequireDefault(_sanitizeOrder);

var _processOrderUps = require('./processOrderUps');

var _processOrderUps2 = _interopRequireDefault(_processOrderUps);

var _costs = require('./costs/costs');

var _costs2 = _interopRequireDefault(_costs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function processOrder(order) {
  if (!order) {
    return {
      error: "Missing order parameter"
    };
  }
  var sanitizedOrder = (0, _sanitizeOrder2.default)(order);
  if (_sanitizeOrder2.default.error) {
    return {
      error: _sanitizeOrder2.default.error
    };
  }

  (0, _processOrderUps2.default)(sanitizedOrder);

  var costs = (0, _costs2.default)({ order: sanitizedOrder });

  return { totalCost: costs.bestCost.unitCost * sanitizedOrder.quantity };
}
//# sourceMappingURL=processOrder.js.map