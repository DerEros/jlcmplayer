log = require( 'log4js' ).getLogger( "rest_server" )
express = require( 'express' )
_s = require( 'highland' )
_ = require( 'lodash' )
bodyParser = require( 'body-parser' )

class RestServer

  constructor: ( config, @dataAccess ) ->
    log.debug( "Constructing Express app" )

    @config = config || {}
    @port = @config["port"] || 3000

    @app = @_createApp()

  start: ->
    log.info( "Rest server starting on port #{@port}" )
    @app.listen( @port )

  _createApp: ->
    log.trace( "Creating app" )
    app = express()
    app.use(bodyParser.json())
    app.use( "/admin", @_createAdminApp() )

    app.use( express.static("#{__dirname}/public/" ) )

  _createAdminApp: ->
    log.trace( "Creating admin app" )
    adminApp = express()
    adminApp.get( "/", express.static( "#{__dirname}/public/admin.html" ) )

    adminApp.get( "/sources", _.bind( @_listSources, @ ) )
            .post( "/sources", _.bind( @_saveSource, @ ) )

    adminApp

  _listSources: ( req, res ) ->
    @dataAccess.getSources().errors( ( err, push ) -> push( null, { error: err } ) )
                            .map( JSON.stringify )
                            .pipe( res.contentType( 'application/json' ) )

  _saveSource: ( req, res ) ->
    log.debug( "Got save request for source object" )
    @dataAccess.insertSource( req.body ).errors( ( err, push ) -> push( null, { error: err } ) )
                                        .map( JSON.stringify )
                                        .pipe( res.contentType( 'application/json' ).status(201) )


module.exports = RestServer
