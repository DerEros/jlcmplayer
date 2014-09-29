#
# NeDB based cache to avoid querying Amazon for the same albums over and over again
#

log = require( 'log4js' ).getLogger( 'cache' )
_s = require( 'highland' )
_ = require( 'lodash' )
Datastore = require( 'nedb' )
crypto = require( 'crypto' )

class Cache
  constructor: ( config ) ->
    log.info( "Constructing Cache" )
    @config = config || {}

    dataDirectory = @config["dataDirectory"] || "#{__dirname}/data"
    dataFile = "#{dataDirectory}/cache.db"

    log.info( "Opening data file #{ dataFile }" )
    @db = new Datastore( { filename: dataFile, autoload: true } )

  getCoverUrl: ( album, artist ) ->
    log.trace( "Checking cache for album #{ album } by #{ artist }")
    _s.wrapCallback( _.bind( @db.find, @db ) )( { _id: @_createId( album, artist ) } )
      .flatten()
      .doto( ( res ) -> if res then log.trace( "Cache hit!" ) )
      .errors( ( err ) -> log.error( "Error retrieving URL from cache. #{ err }" ) )

  setCoverUrl: ( album, artist, url ) ->
    log.trace( "Storing URL for album #{ album } by #{ artist }")
    @db.insert( { _id: @_createId( album, artist ), album: album, artist: artist, url: url }, ( err ) ->
      if err then log.error( "Error caching cover URL. #{ err }" )
    )

  _createId: ( album, artist ) ->
    albumArtist = JSON.stringify( { album: album, artist: artist } )
    crypto.createHash( 'sha1' ).update( albumArtist ).digest( 'base64' )


module.exports = Cache
