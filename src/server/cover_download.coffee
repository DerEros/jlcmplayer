#
# Download cover images based on URLs provided by the cover cache server
#

log = require( 'log4js' ).getLogger( 'cover_download' )
_s = require( 'highland' )
_ = require( 'lodash' )
http = require( 'http' )
fs = require( 'fs' )
su = require( './stream_utils' )

class CoverDownload
  constructor: ( config ) ->
    log.info( "Constructing cover download" )
    @config = config || {}
    @coverDirectory = @config["coverDirectory"] || "#{ __dirname }/covers"
    @coverCacheServerHost = @config[ "coverCacheHost" ] || "localhost"
    @coverCacheServerPort = @config[ "coverCachePort" ] || 80

    fs.mkdirSync( @coverDirectory )

  addCoverFor: ( album ) =>
    log.trace( "Getting cover for album #{ album.title } by #{ album.artist }" )
    @_getCoverUrl( album.title, album.artist )
                .map( JSON.parse )
                .flatMap( ( urlObj ) => @_getCoverImage( album._id, urlObj.url ) )
                .map( ( coverImagePath ) -> _.extend( album, coverImagePath ) )

  _getCoverUrl: ( album, artist ) ->
    log.trace( "Getting cover URL")
    @_httpGetStream( @_createCoverCacheUrl( album, artist ) )
                   .errors( ( err ) -> log.error( "Error retrieving cover URL from cache. #{ err }" ) )
                   .doto( ( res ) -> res.setEncoding( 'utf8' ) )
                   .flatMap( @_response2Stream )
                   .reduce1( @_concat )

  _createCoverCacheUrl: ( album, artist ) ->
    "http://#{ @coverCacheServerHost }:#{ @coverCacheServerPort }/cover?" +
      if album then "album=#{ encodeURIComponent( album ) }" else "" +
      if artist then "&artist=#{ encodeURIComponent( artist ) }" else ""

  _getCoverImage: ( id, url ) ->
    coverImageStream = @_httpGetStream( url )
                                     .errors( ( err ) -> log.error( "Error downloading cover image. #{ err }" ) )
                                     .flatMap( @_response2Stream )

    coverFilePath = "#{ @coverDirectory }/#{ id }"
    log.trace( "About to download cover to #{ coverFilePath }" )
    su.checkExists( coverFilePath )
      .doto( ( exists ) -> log.trace( "File #{ id } exist: #{ exists }." ) )
      .reject( ( exists ) -> exists )
      .map( -> fs.createWriteStream( coverFilePath ) )
      .doto( ( out ) -> out.on( 'finish', -> out.close() ) )
      .doto( ( out ) -> coverImageStream.pipe( out ) )
      .errors( ( err ) -> log.error( "Error storing image. #{ err }" ) )
      .map( -> { coverFilePath } )
      .otherwise( _s( [ { coverFilePath } ] ) )

  _concat: ( a, b ) -> "#{a}#{b}"

  _httpGetStream: ( url ) ->
    _s( ( push ) =>
      http.get( url, ( res ) ->
        push( null, res )
        push( null, _s.nil )
      ).on( 'error', ( err ) ->
        push( err )
        push( null, _s.nil )
      )
    )

  _response2Stream: ( response ) ->
    stream = _s()
    response.pipe( stream )
    stream

module.exports = CoverDownload
