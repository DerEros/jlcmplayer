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
        path: "/mnt/nas/Music"
        active: false
      }
      {
        name: "Local"
        path: "/home/user/Music"
        active: true
      }
      {
        name: "Audiobooks"
        path: "/mnt/audiobooks/files"
        active: true
      }
    ]

module.exports = DummyData
