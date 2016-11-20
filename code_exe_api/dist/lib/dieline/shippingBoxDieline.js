"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _dieline = require("./dieline");

var _dieline2 = _interopRequireDefault(_dieline);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var ShippingBoxDieline = function (_Dieline) {
  _inherits(ShippingBoxDieline, _Dieline);

  function ShippingBoxDieline(args) {
    _classCallCheck(this, ShippingBoxDieline);

    var _this = _possibleConstructorReturn(this, (ShippingBoxDieline.__proto__ || Object.getPrototypeOf(ShippingBoxDieline)).call(this, args));

    _this.style = "Shipping Box";
    return _this;
  }

  _createClass(ShippingBoxDieline, [{
    key: "rectangles",
    value: function rectangles() {

      return [{
        width: 4 * this.length + 14 * this.thickness,
        length: this.depth + this.width + 5 * this.thickness
      }];
    }
  }]);

  return ShippingBoxDieline;
}(_dieline2.default);

exports.default = ShippingBoxDieline;
//# sourceMappingURL=shippingBoxDieline.js.map