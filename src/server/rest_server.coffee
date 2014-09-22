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
    @app.listen( @port, "0.0.0.0" )

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
            .get( "/sources/:id", _.bind( @_getSource, @ ) )
            .post( "/sources", _.bind( @_saveSource, @ ) )
            .delete( "/sources/:id", _.bind( @_deleteSource, @ ) )

    adminApp

  _getSource: ( req, res ) ->
    @dataAccess.getSource( req.params.id ).errors( ( err, push ) -> push( null, { error: err } ) )
                                          .map( JSON.stringify )
                                          .pipe( res.contentType( 'application/json' ) )

  _listSources: ( req, res ) ->
    @dataAccess.getSources().errors( ( err, push ) -> push( null, { error: err } ) )
                            .map( JSON.stringify )
                            .pipe( res.contentType( 'application/json' ) )

  _saveSource: ( req, res ) ->
    log.debug( "Got save request for source object" )
    @dataAccess.upsertSource( req.body ).errors( ( err, push ) -> push( null, { error: err } ) )
                                        .map( JSON.stringify )
                                        .pipe( res.contentType( 'application/json' ).status(201) )

  _deleteSource: ( req, res ) ->
    log.debug( "Got delete request for source object" )
    @dataAccess.deleteSource( req.params.id ).errors( ( err, push ) -> push( null, { error: err } ) )
                                             .map( JSON.stringify )
                                             .pipe( res.status(204) )

module.exports = RestServer
