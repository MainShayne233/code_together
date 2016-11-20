'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = quadExpressOrderCosts;

var _mailerBoxDieline = require('../dieline/mailerBoxDieline');

var _mailerBoxDieline2 = _interopRequireDefault(_mailerBoxDieline);

var _shippingBoxDieline = require('../dieline/shippingBoxDieline');

var _shippingBoxDieline2 = _interopRequireDefault(_shippingBoxDieline);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function quadExpressOrderCosts(args) {

  var order = args.order;

  var costs = {};

  var _iteratorNormalCompletion = true;
  var _didIteratorError = false;
  var _iteratorError = undefined;

  try {
    var _loop = function _loop() {
      up = _step.value;

      var sheet = up.sheet;
      var sheetName = sheet.length + 'x' + sheet.width;

      args.sheet = sheet;
      args.up = up.up;
      var boardCount = Math.ceil(order.quantity / up.up.total);
      args.boardCount = boardCount;

      var costsForSheet = {
        cuttingCost: args.cuttingCost ? args.cuttingCost(args) : cuttingCost(args),
        inkCost: args.inkCost ? args.inkCost(args) : inkCost(args),
        printingCost: args.printingCost ? args.printingCost(args) : printingCost(args),
        boardCost: args.boardCost ? args.boardCost(args) : boardCost(args),
        up: up
      };

      var costTypes = ['cuttingCost', 'inkCost', 'printingCost', 'boardCost'];

      var unitCosts = costTypes.map(function (costType) {
        return costsForSheet[costType];
      });

      costsForSheet.unitCost = unitCosts.reduce(function (x, y) {
        return x + y;
      });

      costsForSheet.boardCount = boardCount;

      costs[sheetName] = costsForSheet;
    };

    for (var _iterator = order.ups[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
      var up;

      _loop();
    }
  } catch (err) {
    _didIteratorError = true;
    _iteratorError = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion && _iterator.return) {
        _iterator.return();
      }
    } finally {
      if (_didIteratorError) {
        throw _iteratorError;
      }
    }
  }

  var sheetNames = Object.keys(costs);
  var allCosts = sheetNames.map(function (sheetName) {
    return costs[sheetName];
  });
  costs.bestCost = {};
  var _iteratorNormalCompletion2 = true;
  var _didIteratorError2 = false;
  var _iteratorError2 = undefined;

  try {
    for (var _iterator2 = allCosts[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
      var cost = _step2.value;

      if (!costs.bestCost.unitCost || costs.bestCost.unitCost > cost.unitCost) {
        costs.bestCost = cost;
      }
    }
  } catch (err) {
    _didIteratorError2 = true;
    _iteratorError2 = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion2 && _iterator2.return) {
        _iterator2.return();
      }
    } finally {
      if (_didIteratorError2) {
        throw _iteratorError2;
      }
    }
  }

  costs.quantity = order.quantity;
  return costs;
}

function cuttingCost(args) {
  var order = args.order;
  var style = order.style;
  var flute = order.flute;
  if (style == 'shipping box') {
    return 0.50;
  } else {
    return flute == 'B' ? 0.90 : 0.60;
  }
}

function printingCost(args) {
  var order = args.order;
  var boardCount = args.boardCount;
  var costPerBoard = 0;
  costPerBoard += order.inkInterior ? 2 : 0;
  costPerBoard += order.inkExterior ? 2 : 0;
  var totalBoardCost = costPerBoard * boardCount;
  var unitCost = totalBoardCost / order.quantity;
  return unitCost;
}

function inkCost(args) {
  var order = args.order;

  var dieline_args = {
    length: order.length,
    width: order.width,
    depth: order.depth,
    stock: order.flute
  };

  var box;

  if (order.style == "mailer box") {
    box = new _mailerBoxDieline2.default(dieline_args);
  } else if (order.style == "shipping box") {
    box = new _shippingBoxDieline2.default(dieline_args);
  } else {
    box = new _mailerBoxDieline2.default(dieline_args);
  }

  var rectangles = box.rectangles();
  var areas = rectangles.map(function (rectangle) {
    return rectangle.length * rectangle.width;
  });
  var totalSquareInches = areas.reduce(function (x, y) {
    return x + y;
  }) - (order.style == "mailer box" ? 2 * box.width * box.depth : 0);
  var totalSquareFeet = totalSquareInches / 144.0;

  var costPerSquareFoot = 0.124;

  var inkCoverage = (order.inkInterior || 0) + (order.inkExterior || 0); // / 100.0

  return inkCoverage * totalSquareFeet * costPerSquareFoot / 100.0;
}

function boardCost(args) {
  var order = args.order;
  var sheet = args.sheet;
  var boardCount = args.boardCount;
  var material = order.material;
  var color = order.color;
  var key;

  if (material == "kemi") {
    key = 'kemi ' + sheet.length + ' x ' + sheet.width;
  } else if (material == "kraft") {
    key = 'kraft ' + sheet.length + ' x ' + sheet.width;
  } else if (material == 'corrugated') {
    key = 'white ' + sheet.length + ' x ' + sheet.width;
  } else {
    key = 'white ' + sheet.length + ' x ' + sheet.width;
  }

  var costOfBoard = {
    "kraft 48 x 96": 3.15,
    "kraft 60 x 100": 4.11,

    "white 48 x 96": 3.55,
    "white 60 x 100": 4.63,

    "kemi 48 x 96": 3.74,
    "kemi 60 x 100": 4.80,

    "18pt 48 x 96": 3.50,
    "18pt 60 x 120": 5.47,

    "24pt 48 x 96": 4.00,
    "24pt 60 x 120": 6.25
  }[key];

  var totalBoardCost = costOfBoard * boardCount;
  var unitCost = totalBoardCost / order.quantity;
  return unitCost;
}
//# sourceMappingURL=quadExpressCosts.js.map