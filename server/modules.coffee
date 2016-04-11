'use strict'

ioc = require "electrolyte"
DIST = if process.env.NODE_ENV == 'test' then 'server' else 'dist'

ioc.use(ioc.node_modules())
ioc.use('controllers', ioc.node(DIST + '/controllers'))
ioc.use('models', ioc.node(DIST + '/models'))
ioc.use('helpers', ioc.node(DIST + '/helpers'))
ioc.use('middlewares', ioc.node(DIST + '/middlewares'))
ioc.use(ioc.node('dist/components'))
module.exports = ioc