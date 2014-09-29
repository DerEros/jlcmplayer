#
# Implementation of the Amazon AWS REST interface to retrieve cover images
#

log = require( 'log4js' ).getLogger( "amazon_cover_api" )
validator = require( 'validator' )
crypto = require( 'crypto' )
fs = require( 'fs' )
_ = require( 'lodash' )
_s = require( 'highland' )
xml2js = require( 'xml2js' )
util = require( 'util' )
url = require( 'url' )
http = require( 'http' )

class AmazonCoverAPI
  constructor: ( config ) ->
    @config = config || {}
    @secret = {}

    @DEFAULT_AMAZON_DOMAIN = "webservices.amazon.com"
    @DEFAULT_AMAZON_RESOURCE = "/onca/xml"
    @DEFAULT_METHOD = "GET"

    @_loadSecrets( __dirname + '/amazon_secret.json' )

  getCover: ( album, artist ) ->
    log.debug( "Getting cover for album #{album} by #{artist}" )

    params =
      Service: "AWSECommerceService"
      Operation: "ItemLookup"
      ResponseGroup: "Images"
      IdType: "ASIN"

    @getAlbumId( album, artist )
        .errors( ( err ) -> log.error( "Cannot get cover without album ID", err ) )
        .map( ( albumId ) -> _s.set( 'ItemId', albumId, params) )
        .map( @_generateURL )
        .flatMap( @_sendRequest )
        .reduce1( @_concat )
        .flatMap( @_parserXmlToStream )
        .errors( ( err ) -> log.error( "Error parsing details. #{ err }" ) )
        .map( @_findImgLink )
        .each( ( result ) -> log.warn( util.inspect(result, false, null ) ) )


  getAlbumId: ( album, artist ) ->
    params =
      Service: "AWSECommerceService"
      Operation: "ItemSearch"
      SearchIndex: "Music"

    if album then _.assign( params, { Title: album } )
    if artist then _.assign( params, { Artist: artist } )

    fullUrl = @_generateURL( params )
    @_sendRequest( fullUrl ).reduce1( @_concat )
                            .flatMap( @_parserXmlToStream )
                            .errors( ( err ) -> log.error( "Error parsing search result. #{ err }" ) )
                            .map( @_findItemId )

  _sendRequest: ( fullUrl, method = @DEFAULT_METHOD ) ->
    out = _s()
    parsedUrl = url.parse( fullUrl )
    options =
      host: url.host
      port: url.port
      path: fullUrl
      method: method
      headers: {
        Host: parsedUrl.host
      }

    log.trace( "Sending request to #{ parsedUrl.host }" )
    req = http.request( options, ( res ) -> res.setEncoding( 'utf8' ); res.pipe( out ) )
    req.on( 'error', ( err ) -> log.error( "Request error.", err ) )
    req.end()

    out

  _findItemId: ( searchResult ) ->
    try
      searchResult.ItemSearchResponse.Items[0].Item[0].ASIN[0]
    catch error
      log.error( "Error getting item ID from search result. #{error}" )
      throw error

  _findImgLink: ( searchResult ) ->
    try
      searchResult.ItemLookupResponse.Items[0].Item[0].LargeImage[0].URL
    catch error
      log.error( "Error getting image link from search result. #{error}" )
      throw error

  _loadSecrets: ( filename ) ->
    log.trace( "Loading secrets from #{ filename }")
    try
      data = fs.readFileSync(filename)
      @_setSecrets( JSON.parse( data ) )
    catch error
      log.error("Could not load secret from #{ filename }. #{error}")

  _setSecrets: ( secrets ) ->
    log.trace( "Setting secrets" )
    @secret.AWSAccessKeyId = secrets.AWSAccessKeyId
    @secret.AssociateTag = secrets.AssociateTag
    @secret.secret = secrets.secret

  _generateURL: ( params,
                  method = @DEFAULT_METHOD,
                  domain = @DEFAULT_AMAZON_DOMAIN,
                  resource = @DEFAULT_AMAZON_RESOURCE) =>
    [ paramStr, signature ] = @_calcSignature( params, method, domain, resource )

    "http://#{ domain }/#{ resource }?#{ paramStr }&Signature=#{ signature }"

  _calcSignature: ( params, method, domain, resource ) ->
    if !@secret then return

    params.AWSAccessKeyId = @secret.AWSAccessKeyId
    params.AssociateTag = @secret.AssociateTag
    params.Timestamp = new Date().toISOString()

    paramStr = _( params ).pairs()
                          .map( ( kv ) -> { key: kv[0], value: kv[1] })
                          .sortBy( 'key' )
                          .map( ( kv ) -> { key: kv.key, value: encodeURIComponent( kv.value ) } )
                          .map( ( kv ) -> "#{ kv.key }=#{ kv.value }")
                          .foldl( ( sum, param ) -> "#{ sum }&#{ param }")
    strToSign = "#{ method }\n#{ domain }\n#{ resource }\n#{ paramStr }"

    signature = crypto.createHmac( 'SHA256', @secret.secret ).update( strToSign ).digest( 'base64' );
    [ paramStr, encodeURIComponent( signature ) ]

  _parserXmlToStream: _s.wrapCallback( xml2js.parseString )

  _concat: ( a, b ) -> "#{a}#{b}"

module.exports = AmazonCoverAPI
