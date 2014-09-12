#
# Collection of methods to retrieve and write data from and to the database
#

log = require( 'log4js' ).getLogger( 'data_access' )
_s = require( 'highland' )

class DataAccess
  constructor: ( config ) ->
    log.debug( "Constructing data access object" )
    @config = config || {}
    @dataDirectory = @config["dataDirectory"] || "#{__dirname}/data"

  #
  # Get all source objects from the data base as a stream of JSON objects
  #
  getSources: ->
    log.trace( "Getting data sources" )
    dummy = {
      path: "/foo/bar"
      name: "FooBar"
      _id: "12345"
      active: true
    }

    _s( [ dummy ] )

module.exports = DataAccess
