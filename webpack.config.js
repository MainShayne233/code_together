var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");


module.exports = {
  entry: ["./web/static/js/app.js", "./web/static/css/app.scss"],
  output: {
    path: "./priv/static",
    filename: "js/app.js"
  },

  resolve: {
    modulesDirectories: [ "node_modules", __dirname + "/web/static/js" ]
  },

  module: {
    loaders: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel",
      include: __dirname,
      query: {
        presets: ["es2015"]
      }
    },
    {
      test: /\.css$/,
      loader: ExtractTextPlugin.extract("style", "css")
    },
    {
      test: /\.scss$/,
      loader: ExtractTextPlugin.extract("style", "css!sass")
    }]
  },

  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new CopyWebpackPlugin([{ from: "./web/static/assets" }])
  ]
};
