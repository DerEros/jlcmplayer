logConfigurator = require( './logger_config' )
RestServer = require( './rest_server' )
log = require( 'log4js' ).getLogger( 'server' )
DataAccess = require( './data_access' )
MusicScanner = require( './music_scanner' )
DummyData = require( './dummy_data' )
_s = require( 'highland' )

writeDummyDataToDb = ( dataAccess ) ->
  log.warn("Filling DB with dummy data")

  dummyDataProducer = new DummyData()
  dummyData = dummyDataProducer.produceData()

  _s(dummyData.sources).flatMap( (source) -> dataAccess.insertSource( source ) ).each( (result) ->
    log.trace("Wrote #{result._id}")
  )

main = () ->
  log.info( "Starting Server" )
  config = {
    coverCacheHost: "localhost"
    coverCachePort: 4000
    coverDirectory: "#{__dirname}/covers"
  }

  dataAccess = new DataAccess( config )
  musicScanner = new MusicScanner( config )

  writeDummyDataToDb( dataAccess )

  rs = new RestServer( config, dataAccess, musicScanner )
  rs.start()

  log.info( "Server started" )


logConfigurator.config( main )

