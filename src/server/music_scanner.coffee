#
# Functinality to scan through a list of directories, identify all the supported media files and gather their meta-data.
# Also groups media into lists (usually albums) based on their metadata
#

log = require( 'log4js' ).getLogger( 'music_scanner' )
_s = require( 'highland' )
_ = require( 'lodash' )
filewalker = require( 'filewalker' )
fs  = require( 'fs' )
lame = require( 'lame' )
crypto = require( 'crypto' )

class MusicScanner
  constructor: ( @config ) ->
    log.debug( "Constructing music scanner" )

  scan: ( sources ) ->
    log.debug( "About to scan now" )
    sources.map( @_filesByPattern( /.*\.mp3$/ ) )
           .flatten()
           .map( @_getID3 )
           .parallel( 10 )
           .flatten()
           .map( @_reduceTagsObj )
           .doto( @_logTags )

  #
  # Scan for files matching the given pattern starting in the directory with basePath
  #
  _filesByPattern: ( pattern ) -> ( source )->
    stream = _s().on( 'drain', -> walker.resume() )

    walker = filewalker( source.path )
      .on( 'file', ( p ) ->
        more = if pattern.test( p ) then stream.write( "#{source.path}/#{p}" ) else true

        if !more then walker.pause()
      )
      .on( 'done', -> stream.destroy() )
      .walk()

    stream

  #
  # Open the specified MP3 file and read the ID3 tags
  #
  _getID3: ( path ) ->
    _s( ( push ) ->
      fs.createReadStream( path )
        .pipe( new lame.Decoder() )
        .on( 'id3v1', ( tags ) ->
          push( null, _s.set( 'path', path, tags ) )
          push( null, _s.nil )
        )
        .on( 'id3v2', ( tags ) ->
          push( null, _s.set( 'path', path, tags ) )
          push( null, _s.nil )
        )
    )

  #
  # Reduce tags object to necessary values
  #
  _reduceTagsObj: ( tags ) =>
    baseTags =
      _id: @_createId( tags )
      path: tags.path
      title: tags.title
      album: tags.album
      artist: tags.artist

    if ( trck = _.find( tags.texts, { id: 'TRCK' } ) ) then _.assign( baseTags, @_parseTrack( trck.text ) )

    baseTags

  #
  # Parse the tracks string which has a format like '2/13' (track #2 out of 13) into two numbers
  #
  _parseTrack: ( trackStr ) ->
    log.trace("Parsing trackStr: #{trackStr}")
    {
      track: Number( trackStr.match( /^(\d*).*/ )[1] )
    }

  #
  # Calculates a unique ID based on artist, title and album
  #
  _createId: ( tags ) ->
    id = crypto.createHash( 'sha1' )
    id.update( tags.title )
    id.update( tags.album )
    id.update( tags.artist )
    id.digest( 'base64' )

  _logTags: ( tags ) -> log.trace("Got title '#{ tags.title }' from '#{ tags.album }' (#{ tags.artist })" )

module.exports = MusicScanner
