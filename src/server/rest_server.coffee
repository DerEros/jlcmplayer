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
    @dataAccess.getSource( req.params.id ).map( @_withRes( res ) )
                                          .map( @_withStatus( 200 ) )
                                          .map( @_withContentType( 'application/json' ) )
                                          .errors( @_errorWithStatus( res, 404 ) )
                                          .map( @_stringify )
                                          .each( @_send )

  _listSources: ( req, res ) ->
    @dataAccess.getSources().errors( ( err, push ) -> push( null, { error: err } ) )
                            .map( JSON.stringify )
                            .pipe( res.contentType( 'application/json' ) )

  _saveSource: ( req, res ) ->
    log.debug( "Got save request for source object" )
    @dataAccess.upsertSource( req.body ).map( @_withRes( res ) )
                                        .map( @_withStatus( 201 ) )
                                        .map( @_withContentType( 'application/json' ) )
                                        .errors( @_errorWithStatus( res, 500 ) )
                                        .map( @_stringify )
                                        .each( @_send )

  _deleteSource: ( req, res ) ->
    log.debug( "Got delete request for source object" )
    @dataAccess.deleteSource( req.params.id ).map( @_withRes( res ) )
                                             .map( @_withStatus( 204 ) )
                                             .map( @_withContentType( 'application/json' ) )
                                             .errors( @_errorWithStatus( res, 500 ) )
                                             .map( @_stringify )
                                             .each( @_send )

  # Utility functions
  #####################

  # Add ExpressJS result object to the data stream
  _withRes: ( res ) -> ( data ) -> { res: res, data: data }

  # Put an error status code into the stream and forward the error message as data
  _errorWithStatus: ( res, status ) -> ( err, push ) -> push( null, { res: res.status( status ), data: err } )

  # Set the status within the streamed result object. Use _withRes first
  _withStatus: ( status ) -> ( { res, data } ) -> { res: res.status( status ), data: data }

  # Set a content type within the result object. Use _withRes first
  _withContentType: (type) -> ( dataWithRes ) -> _.assign( dataWithRes, { res: dataWithRes.res.contentType( type ) } )

  # Convert the data object in the stream to a JSON string. Use _withRes first
  _stringify: ( dataWithRes ) -> _.assign( dataWithRes, { data: JSON.stringify( dataWithRes.data ) } )

  # Send the streamed data using the also streamd result object. Use _withRes first
  _send: ( { res, data } = dataWithRes ) -> res.send( data )

module.exports = RestServer
