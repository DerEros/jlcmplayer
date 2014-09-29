#
# REST service to query for cover images
#

express = require( 'express' )
log = require( 'log4js' ).getLogger( 'rest_server' )

class RestServer
  constructor: ( config ) ->
    log.info( "Constructing Express app" )

    @config = config || {}
    @port = @config["port"] || 4000

    @app = @_createApp()

  start: () ->
    log.info( "Rest server starting on port #{@port}" )
    @app.listen( @port, "0.0.0.0" )

  _createApp: ->
    log.trace( "Creating app" )
    app = express()

    app.get("/cover", @_getCover)

  _getCover: ( req, res ) ->
    log.trace( "Getting cover" )
    album = req.query.album
    artist = req.query.artist


module.exports = RestServer
