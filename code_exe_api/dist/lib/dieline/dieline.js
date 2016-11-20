'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Dieline = function () {
  function Dieline(args) {
    _classCallCheck(this, Dieline);

    this.length = args.length;
    this.width = args.width;
    this.depth = args.depth;
    this.thickness = (args.stock || '').toLowerCase() == 'b' ? 0.125 : 0.0625;
  }

  _createClass(Dieline, [{
    key: 'height',
    value: function height() {
      return this.rectangles().map(function (rectangle) {
        return rectangle.length;
      }).reduce(function (x, y) {
        return x + y;
      });
    }
  }, {
    key: 'ups_for',
    value: function ups_for(args) {
      var _this = this;

      return args.sheets.map(function (sheet) {
        return {
          sheet: sheet,
          up: _this.up_for({ sheet: sheet })
        };
      });
    }
  }, {
    key: 'up_for',
    value: function up_for(args) {
      var sheet;
      if (args.sheet.length < args.sheet.width) {
        sheet = {
          width: args.sheet.length,
          length: args.sheet.width
        };
      } else {
        sheet = args.sheet;
      }

      var rectangles = this.rectangles();

      if (rectangles.length == 1) {

        var across = this.max_width_count_for({
          sheet: sheet,
          index: index,
          jndex: jndex
        });

        var down = this.max_length_count_for({
          sheet: sheet,
          index: index,
          jndex: jndex
        });

        var _up = across * down;

        return {
          total: _up,
          across: across,
          down: down
        };
      }

      var ups = [];

      for (var index = 0; index < rectangles.length - 1; index++) {
        for (var jndex = index + 1; jndex < rectangles.length; jndex++) {
          var _across = this.max_width_count_for({
            sheet: sheet,
            index: index,
            jndex: jndex
          });

          var _down = this.max_length_count_for({
            sheet: sheet,
            index: index,
            jndex: jndex
          });

          var _up2 = _across * _down;
          ups.push({
            total: _up2,
            across: _across,
            down: _down
          });
        }
      }

      var best_up = {};
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = ups[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var up = _step.value;

          if (!best_up.total || up.total > best_up.total) {
            best_up = up;
          }
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

      return best_up;
    }
  }, {
    key: 'coordinates',
    value: function coordinates() {
      var args = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

      var rectangles = this.rectangles();
      if (args.reversed) {
        rectangles.reverse();
      }
      var points = [[0, 0]];
      var last_points = points[0];
      for (var _index in rectangles) {
        var rectangle = rectangles[_index];
        if (_index > 0) {
          last_points = [last_points[0] + (rectangle.width - rectangles[_index - 1].width) / 2, last_points[1]];
          points.push(last_points);
          last_points = [last_points[0], last_points[1] - rectangle.length];
          points.push(last_points);
        } else {
          last_points = [last_points[0] + rectangle.width, last_points[1]];
          points.push(last_points);
          last_points = [last_points[0], last_points[1] - rectangle.length];
          points.push(last_points);
        }
      }
      rectangles.reverse();
      for (var _index2 in rectangles) {
        var _rectangle = rectangles[_index2];
        if (_index2 > 0) {
          last_points = [last_points[0] - (_rectangle.width - rectangles[_index2 - 1].width) / 2, last_points[1]];
          points.push(last_points);
          last_points = [last_points[0], last_points[1] + _rectangle.length];
          points.push(last_points);
        } else {
          last_points = [last_points[0] - _rectangle.width, last_points[1]];
          points.push(last_points);
          last_points = [last_points[0], last_points[1] + _rectangle.length];
          points.push(last_points);
        }
      }
      return points;
    }
  }, {
    key: 'max_width_and_height_for',
    value: function max_width_and_height_for(args) {
      var sheet = args.sheet;
      var rectanlges = args.rectangles;
      var pivot_rectangle_1 = rectangles[args.index];
      var pivot_rectangle_2 = rectangles[args.jndex];
    }
  }, {
    key: 'max_width_count_for',
    value: function max_width_count_for(args) {
      var sheet = args.sheet;
      var spacing = args.spacing || 1;
      var rectangles = this.biggest_difference_rectangles();
      var smaller_rectangle = rectangles.smaller_rectangle;
      var bigger_rectangle = rectangles.bigger_rectangle;
      var width = bigger_rectangle.width + spacing;
      var count = 0;
      if (width + spacing > sheet.width) {
        return count;
      } else {
        count += 1;
        var another = bigger_rectangle.width - (bigger_rectangle.width - smaller_rectangle.width) / 2 + spacing;
        while (width + another < sheet.width) {
          width += another;
          count += 1;
        }
      }
      return count;
    }
  }, {
    key: 'max_length_count_for',
    value: function max_length_count_for(args) {
      var sheet = args.sheet;
      var spacing = args.spacing || 1;
      var rectangles = this.rectangles();
      var length = rectangles.map(function (rect) {
        return rect.length;
      }).reduce(function (r1, r2) {
        return r1 + r2;
      });
      var count = 0;
      while (length * (count + 1) + spacing * (count + 1) < sheet.length) {
        count += 1;
      }
      return count;
    }
  }, {
    key: 'biggest_difference_rectangles',
    value: function biggest_difference_rectangles() {
      var rectangles = this.rectangles();

      var biggest_difference = {
        difference: 0
      };

      if (rectangles.length == 1) {
        var rectangle1 = rectangles[0];
        var rectangle2 = rectangles[0];
        biggest_difference.difference = 0;
        biggest_difference.bigger_rectangle = rectangle1;
        biggest_difference.bigger_rectangle.index = 0;
        biggest_difference.smaller_rectangle = rectangle2;
        biggest_difference.smaller_rectangle.index = 0;
        return biggest_difference;
      }

      for (var index = 0; index < rectangles.length - 1; index++) {
        for (var jndex = index + 1; jndex < rectangles.length; jndex++) {
          var _rectangle2 = rectangles[index];
          var _rectangle3 = rectangles[jndex];
          var difference = _rectangle2.width - _rectangle3.width;
          var absolute_difference = Math.abs(difference);

          if (absolute_difference > biggest_difference.difference) {
            if (difference > 0) {
              biggest_difference.bigger_rectangle = _rectangle2;
              biggest_difference.bigger_rectangle.index = index;
              biggest_difference.smaller_rectangle = _rectangle3;
              biggest_difference.smaller_rectangle.index = jndex;
            } else {
              biggest_difference.bigger_rectangle = _rectangle3;
              biggest_difference.bigger_rectangle.index = jndex;
              biggest_difference.smaller_rectangle = _rectangle2;
              biggest_difference.smaller_rectangle.index = index;
            }
            biggest_difference.difference = difference;
          } else {
            biggest_difference.bigger_rectangle = _rectangle2;
            biggest_difference.bigger_rectangle.index = index;
            biggest_difference.smaller_rectangle = _rectangle3;
            biggest_difference.smaller_rectangle.index = jndex;
          }
        }
      }
      return biggest_difference;
    }
  }]);

  return Dieline;
}();

exports.default = Dieline;
//# sourceMappingURL=dieline.js.map