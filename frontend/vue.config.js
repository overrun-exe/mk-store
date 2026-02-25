const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: true,
  devServer: {
    allowedHosts: 'all'
  },
  publicPath: process.env.VUE_APP_PUBLIC_PATH || '/'
})
