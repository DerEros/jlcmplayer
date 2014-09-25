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
  ,
    name: 'lists'
    filename: 'lists.db'
    autoload: true
  ,
    name: 'media'
    filename: 'media.db'
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
  # Get a source object from the data base as a stream of JSON objects
  #
  getSource: (id) ->
    log.trace( "Getting data source #{id}" )
    @_findStream( @db.sources.find( { _id: id } ) ).errors( streamUtils.logAndForwardError( log, "Error getting source: " ) )

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

  #
  # Write one source object to database - either insert or update depending on its existence
  #
  upsertSource: ( source ) ->
    log.trace( "Upserting source object ")
    streamUtils.streamify3( @db.sources, @db.sources.update, { _id: source._id }, source, { upsert: true } )
               .errors( streamUtils.logAndForwardError( log, "Error upserting source: " ) )
               .doto( ( [ num, doc ] ) -> log.trace("Upserted #{num} objects" ) )
               .map( ( [ num, doc ] ) -> doc )

  #
  # Delete one source object from database
  #
  deleteSource: ( sourceId ) ->
    log.trace( "Deleting source object #{sourceId}" )
    streamUtils.streamify( @db.sources, @db.sources.remove, { _id: sourceId }, {} )
               .errors( streamUtils.logAndForwardError( log, "Error deleting source: " ) )
               .doto( (num) -> log.trace("Deleted #{num} objects" ) )

  #
  # Write one media object to database - either insert or update depending on its existence
  #
  upsertMedia: ( media ) ->
    log.trace( "Upserting media object " )
    streamUtils.streamify3( @db.media, @db.media.update, { _id: media._id }, media, { upsert: true } )
               .errors( streamUtils.logAndForwardError( log, "Error upserting media: " ) )
               .doto( ( [ num, doc ] ) -> log.trace("Upserted #{num} objects" ) )
               .map( ( [ num, doc ] ) -> doc )


module.exports = DataAccess
