logConfigurator = require('./logger_config')
RestServer = require('./rest_server')
log = require('log4js').getLogger('server')

main = () ->
  log.info("Starting Server")

  rs = new RestServer()
  rs.start()

  log.info("Server started")


logConfigurator.config(main)

