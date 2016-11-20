'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = processOrderUps;

var _mailerBoxDieline = require('./dieline/mailerBoxDieline');

var _mailerBoxDieline2 = _interopRequireDefault(_mailerBoxDieline);

var _shippingBoxDieline = require('./dieline/shippingBoxDieline');

var _shippingBoxDieline2 = _interopRequireDefault(_shippingBoxDieline);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function processOrderUps(order) {

  var box;
  if (order.style === 'mailer box') {
    box = new _mailerBoxDieline2.default(order);
  } else if (order.style == 'shipping box') {
    box = new _shippingBoxDieline2.default(order);
  } else {
    return {
      error: order.style + ' is not a supported style'
    };
  }

  var sheets = [{
    length: 48,
    width: 96
  }];

  order.ups = box.ups_for({ sheets: sheets });
}
//# sourceMappingURL=processOrderUps.js.map