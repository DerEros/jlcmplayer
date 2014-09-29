#
# Reusable utility functions
#

_s = require( 'highland' )
urlUtil = require( 'url' )
http = require( 'http' )
log = require( 'log4js' ).getLogger( 'utils' )
xml2js = require( 'xml2js' )

GET = ( url, proxy, proxyPort ) ->
  parsedUrl = urlUtil.parse( url )

  if proxy
    options =
      host: proxy
      port: proxyPort
      path: url
      method: "GET"
      headers: {
        Host: parsedUrl.host
      }
  else
    options = url

  _s( ( push ) ->
    req = http.request( options, ( res ) ->
      push( null, res )
      push( null, _s.nil )
    )

    req.on( 'error', ( err ) ->
      push( err )
      push( null, _s.nil )
    )

    req.end()
  )

response2Stream = ( response ) ->
  stream = _s()
  response.pipe( stream )
  stream

concatParseXml = ( stream ) ->
  stream.reduce1( _concat )
        .flatMap( _parserXmlToStream )
        .errors( ( err ) -> log.error( "Error parsing search result. #{ err }" ) )

_parserXmlToStream = _s.wrapCallback( xml2js.parseString )

_concat = ( a, b ) -> "#{a}#{b}"

module.exports =
  GET: GET
  response2Stream: response2Stream
  concatParseXml: concatParseXml
