log = require( 'log4js' ).getLogger( "rest_server" )
express = require( 'express' )
_s = require( 'highland' )
_ = require( 'lodash' )

DataAccess = require( './data_access' )

class RestServer

  constructor: ( config ) ->
    log.debug( "Constructing Express app" )

    @config = config || {}
    @port = @config["port"] || 3000

    @dataAccess = new DataAccess( config )
    @app = @_createApp()

  start: ->
    log.info( "Rest server starting on port #{@port}" )
    @app.listen( @port )

  _createApp: ->
    log.trace( "Creating app" )
    app = express()
    app.use( "/admin", @_createAdminApp() )

  _createAdminApp: ->
    log.trace( "Creating admin app" )
    adminApp = express()
    adminApp.get( "/", express.static( "#{__dirname}/public/admin.html" ) )

    adminApp.get( "/sources", _.bind( @_listSources, @ ) )

    adminApp

  _listSources: ( req, res ) ->
    @dataAccess.getSources().errors( ( err, push ) -> push( null, { error: err } ) )
                            .map( JSON.stringify )
                            .pipe( res.contentType( 'application/json' ) )


module.exports = RestServer
