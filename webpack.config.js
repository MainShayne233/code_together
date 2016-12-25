var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");


module.exports = {
  entry: ["./web/static/js/app.js", "./web/static/css/app.css"],
  output: {
    path: "./priv/static",
    filename: "js/app.js"
  },

  resolve: {
    modulesDirectories: [ "node_modules", __dirname + "/web/static/js" ]
  },

  module: {
    loaders: [{
      test: /\.(js|jsx)$/,
      exclude: /node_modules/,
      loader: "babel",
      include: __dirname,
      query: {
        presets: ['es2015', 'stage-0', 'react'],
      },
    },
    {
      test: /\.css$/,
      loader: ExtractTextPlugin.extract("style", "css"),
    },
    {
      test: /\.scss$/,
      loader: ExtractTextPlugin.extract("style", "css!sass"),
    },
    {
      test: /\.svg/,
      loader: 'svg-url-loader',
    },
    {
      test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
      loader: "url-loader?limit=10000&mimetype=application/font-woff",
    },
    {
      test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
      loader: "file",
    },
    {
      test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
      loader: "url?limit=10000&mimetype=application/octet-stream",
    },
    { test: /\.(png|jpg)$/,
      loader: 'url-loader?prefix=assets/'
    },
  ]
  },

  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new CopyWebpackPlugin([{ from: "./web/static/assets" }]),
  ]
};
