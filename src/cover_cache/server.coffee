#
# Entry point for the album cover image cache
#

log = require( 'log4js' ).getLogger( 'server' )
RestServer = require( './rest_server' )
AmazonCoverApi = require( './amazon_cover_api' )
Cache = require( './cache' )

main = () ->
  log.info( 'Starting cover image cache server' )
  config = {}

  cache = new Cache( config )

  rs = new RestServer( config, cache, new AmazonCoverApi( config ) )
  rs.start()


main()
