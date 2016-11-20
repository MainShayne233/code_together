'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = sanitizeOrder;
function sanitizeOrder(order) {

  var sanitizedOrder = {
    length: sanitizeFloat(order.length),
    width: sanitizeFloat(order.width),
    depth: sanitizeFloat(order.depth),
    style: sanitizeString(order.style),
    material: sanitizeString(order.material),
    color: sanitizeString(order.color),
    stock: sanitizeStock(order.stock),
    quantity: sanitizeNumber(order.quantity),
    inkExterior: sanitizeFloat(order.inkExterior),
    inkInterior: sanitizeFloat(order.inkInterior)
  };

  var necessaryAttrs = ['length', 'width', 'depth', 'style', 'material', 'color', 'stock', 'quantity'];

  var missingAttrs = necessaryAttrs.filter(function (attr) {
    return sanitizedOrder[attr] === 'missing';
  });
  if (missingAttrs.length) {
    return {
      error: 'Missing: ' + missingAttrs.join(', ')
    };
  }

  return sanitizedOrder;
}

function sanitizeStock(stock) {
  return sanitizeString(stock).replace('-flute', '');
}

function sanitizeParam(param) {
  var sanitize = _.camelCase(param);
  return sanitize === '' ? 'missing' : sanitize;
}

function sanitizeString(string) {
  return string ? string.toLowerCase() : 'missing';
}

function sanitizeFloat(float) {
  return float ? parseFloat(float) : 'missing';
}

function sanitizeNumber(number) {
  return number ? parseInt(number) : 'missing';
}
//# sourceMappingURL=sanitizeOrder.js.map