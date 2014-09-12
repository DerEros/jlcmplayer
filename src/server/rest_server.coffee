log = require('log4js').getLogger("rest_server")


class RestServer
  constructor: ->

  start: ->
    log.info("Rest server started")

module.exports = RestServer
