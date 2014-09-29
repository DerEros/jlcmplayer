#
# Entry point for the album cover image cache
#

log = require( 'log4js' ).getLogger( 'cache' )
RestServer = require( './rest_server' )
AmazonCoverApi = require( './amazon_cover_api' )

main = () ->
  log.info( 'Starting cover image cache server' )
  config = {}

  rs = new RestServer( config, new AmazonCoverApi( config ) )
  rs.start()


main()
