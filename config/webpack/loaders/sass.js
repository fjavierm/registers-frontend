const ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: ExtractTextPlugin.extract({
    fallback: 'style-loader',
    use: [{
      loader: 'css-loader',
      options: {
        modules: true,
        sourceMap: true,
        importLoaders: 2,
        localIdentName: '[name]__[local]___[hash:base64:5]',
        includePaths: [
          "node_modules/govuk_frontend_toolkit/stylesheets",
          "node_modules/govuk-elements-sass/public/sass",
        ]
      }
    },
    'postcss-loader',
    'sass-loader'
    ]
  })
}

//module.exports = {
//   test: /\.(scss|sass|css)$/i,
//   use: [{
//     loader: 'sass-loader',
//     options: {
//       modules: true,
//       sourceMap: true,
//       importLoaders: 2,
//       localIdentName: '[name]__[local]___[hash:base64:5]',
//       includePaths: [
//         path.resolve(__dirname, "node_modules/govuk_frontend_toolkit/stylesheets"),
//         path.resolve(__dirname, "node_modules/govuk-elements-sass/public/sass"),
//       ]
//     }
//   }]
// }

