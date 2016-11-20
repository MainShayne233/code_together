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

var MailerBoxDieline = function (_Dieline) {
  _inherits(MailerBoxDieline, _Dieline);

  function MailerBoxDieline(args) {
    _classCallCheck(this, MailerBoxDieline);

    var _this = _possibleConstructorReturn(this, (MailerBoxDieline.__proto__ || Object.getPrototypeOf(MailerBoxDieline)).call(this, args));

    _this.style = "Mailer Box";
    return _this;
  }

  _createClass(MailerBoxDieline, [{
    key: "rectangles",
    value: function rectangles() {

      var firstRectangleX = this.length + 7 * this.thickness;
      var firstRectangleY = this.depth + this.thickness / 2;
      var firstFlapX = Math.min.apply(Math, [this.depth, this.width / 2]);

      var secondRectangleX = this.length + this.thickness;
      var secondRectangleY = this.width + 2 * this.thickness;
      var secondFlapX = this.depth + this.thickness / 2;

      var thirdRectangleX = this.length + 10 * this.thickness;
      var thirdRectangleY = this.depth + this.thickness;
      var thirdFlapX = this.width / 2 - 2 * this.thickness;

      var fourthRectangleX = this.length + 9 * this.thickness;
      var fourthRectangleY = this.width + this.thickness;
      var fourthFlapX = 2 * this.depth + 6.5 * this.thickness;

      var fifthRectangleX = this.length + 5 * this.thickness;
      var fifthRectangleY = this.depth + this.thickness / 2;
      var fifthFlapX = this.width / 2 + this.thickness / 2;

      return [{
        width: firstRectangleX + 2 * firstFlapX,
        length: firstRectangleY
      }, {
        width: secondRectangleX + 2 * secondFlapX,
        length: secondRectangleY
      }, {
        width: thirdRectangleX + 2 * thirdFlapX,
        length: thirdRectangleY
      }, {
        width: fourthRectangleX + 2 * fourthFlapX,
        length: fourthRectangleY
      }, {
        width: fifthRectangleX + 2 * fifthFlapX,
        length: fifthRectangleY
      }];
    }
  }]);

  return MailerBoxDieline;
}(_dieline2.default);

exports.default = MailerBoxDieline;
//# sourceMappingURL=mailerBoxDieline.js.map