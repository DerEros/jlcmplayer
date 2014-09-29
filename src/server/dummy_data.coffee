log = require( 'log4js' ).getLogger( 'dummy_data' )

class DummyData

  constructor: () ->

  produceData: () ->
    data = {}
    data["sources"] = @produceSources()

    data

  produceSources: () ->
    [
      {
        name: "NAS"
        path: "/home/anony/Music"
        active: true
      }
    ]

module.exports = DummyData
