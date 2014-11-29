@app.controller "PlaylistController",
  class PlaylistController
    @$inject = [ "Restangular" ]

    constructor: ( @Restangular ) ->
      @playlists = []

      @_getPlaylists( {} )

    rescan: ->
      @_getPlaylists( { rescan: true } )

    play: ( id ) ->
      alert( "Playing #{ id }" )

      @Restangular.all( 'player' ).post( 'playlist', { list_id: id } )

    _getPlaylists: ( params ) ->
      @Restangular.all( 'admin' ).all( 'lists' )
      .getList( params )
      .then( ( lists ) => _( lists ).map( ( list ) => _.assign( list, { cover: @_coverURI( list )} ) ).value() )
      .then( @_updateLists )
      .finally( @_unbusy )

    _coverURI: ( list ) -> "admin/lists/#{ list._id }/cover"

    _updateLists: ( newLists ) => @playlists = newLists

    _unbusy: => @busy = false
