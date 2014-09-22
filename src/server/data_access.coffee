#
# Collection of methods to retrieve and write data from and to the database
#

log = require( 'log4js' ).getLogger( 'data_access' )
_s = require( 'highland' )
_ = require( 'lodash' )

streamUtils = require( './stream_utils' )
Datastore = require( 'nedb' )

class DataAccess
  databaseDescriptions = [
    name: 'sources'
    filename: 'sources.db'
    autoload: true
  ]

  constructor: ( config ) ->
    log.debug( "Constructing data access object" )
    @config = config || {}
    @dataDirectory = @config["dataDirectory"] || "#{__dirname}/data"
    @db = {}

    @_loadDatabases( databaseDescriptions )

  #
  # A wrapper around NeDB's db.find method that takes the arguments of the find method's callback and pushes them into
  # a stream. Errors are pushed into the errors side, docs on the data side.
  #
  _findStream: ( find ) -> _s.wrapCallback( _.bind( find.exec, find ) )()

  _loadDatabases: ( databaseNames ) ->
    log.debug( "About to load #{databaseNames.length} databases" )
    _s( databaseNames ).map( _.bind( @_prependDirectory, @ ) )
                        .map( @_createDB )
                        .errors( ( err ) -> log.error( "Loading database failed with error: #{err}" ) )
                        .doto( _.bind( @_addDB, @ ) )
                        .each( ( dbDesc ) -> log.debug( "Successfully loaded database: #{dbDesc.name}" ) )

  _prependDirectory: ( dbDesc ) -> _s.extend( { filename: "#{@dataDirectory}/#{dbDesc.filename}" }, dbDesc )

  _createDB: ( dbDesc ) -> _s.extend( { db: new Datastore( dbDesc ) }, dbDesc )

  _addDB: ( dbDesc ) -> @db[dbDesc.name] = dbDesc.db

  #
  # Get all source objects from the data base as a stream of JSON objects
  #
  getSources: ->
    log.trace( "Getting data sources" )
    @_findStream( @db.sources.find( {} ) ).errors( streamUtils.logAndForwardError( log, "Error getting sources: " ) )

  #
  # Write one source object to the database
  #
  insertSource: (source) ->
    log.trace( "Writing source object ")
    streamUtils.streamify( @db.sources, @db.sources.insert, source )
               .errors( streamUtils.logAndForwardError( log, "Error saving source: " ) )

module.exports = DataAccess
