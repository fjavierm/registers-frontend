const { environment } = require('@rails/webpacker')
const merge = require('webpack-merge')

const sassLoader = environment.loaders.get('sass')
const cssLoader = sassLoader.use.find(loader => loader.loader === 'css-loader')
const path = require('path')

cssLoader.options = Object.assign(cssLoader.options, {
  modules: true,
  localIdentName: '[path][name]__[local]--[hash:base64:5]',
  includePaths: [
    path.resolve(__dirname, "node_modules/govuk_frontend_toolkit/stylesheets"),
    path.resolve(__dirname, "node_modules/govuk-elements-sass/public/sass")
  ]
})

module.exports = environment
