log = require( 'log4js' ).getLogger( "rest_server" )
express = require( 'express' )
_s = require( 'highland' )
_ = require( 'lodash' )
bodyParser = require( 'body-parser' )

class RestServer
  constructor: ( config, @dataAccess, @musicScanner ) ->
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

    adminApp.get( "/lists", _.bind( @_scanSources, @ ) )

    adminApp

  _getSource: ( req, res ) ->
    @dataAccess.getSource( req.params.id ).map( @_withRes( res, 200 ) )
                                          .errors( @_errorWithStatus( res, 404 ) )
                                          .each( @_send )

  _listSources: ( req, res ) ->
    @dataAccess.getSources().map( @_withRes( res, 200 ) )
                            .errors( @_errorWithStatus( res, 404 ) )
                            .each( @_send )

  _saveSource: ( req, res ) ->
    log.debug( "Got save request for source object" )
    @dataAccess.upsertSource( req.body ).map( @_withRes( res, 201 ) )
                                        .errors( @_errorWithStatus( res, 500 ) )
                                        .each( @_send )

  _deleteSource: ( req, res ) ->
    log.debug( "Got delete request for source object" )
    @dataAccess.deleteSource( req.params.id ).map( @_withRes( res, 204 ) )
                                             .errors( @_errorWithStatus( res, 500 ) )
                                             .each( @_send )

  _scanSources: ( req, res ) ->
    if req.query.rescan
      log.debug( "Got scan request: with rescan" )
      activeDataSources = @dataAccess.getSources().flatten().where( { active: true } )
      [ mediaStream, albumStream ] = @musicScanner.scan( activeDataSources )

      albumStream.on('end', => @_sendListsAndMedia( res ) )

      albumStream.each( ( a ) => @dataAccess.upsertList( a ).resume() )
      mediaStream.each( ( m ) => @dataAccess.upsertMedia( m ).resume() )
    else
      log.debug( "Got scan request: without rescan" )
      @_sendListsAndMedia( res )

  _sendListsAndMedia: ( res ) ->
    @dataAccess.getListsAndMedia().map( @_withRes( res, 200 ) )
      .errors( @_errorWithStatus( res, 404 ) )
      .each( @_sendArray )

  # Utility functions
  #####################

  # Add ExpressJS result object to the data stream
  _withRes: ( res, status, contentType = 'application/json' ) -> ( data ) ->
    { res: res.status( status) .contentType( contentType ), data: data }

  # Put an error status code into the stream and forward the error message as data
  _errorWithStatus: ( res, status ) -> ( err, push ) -> push( null, { res: res.status( status ), data: err } )

  # Send the streamed data using the also streamd result object. Use _withRes first
  _send: ( { res, data } = dataWithRes ) -> res.send( JSON.stringify( data ) )
  _sendArray: ( { res, data } = dataWithRes ) -> res.send( JSON.stringify( data ) )

module.exports = RestServer
