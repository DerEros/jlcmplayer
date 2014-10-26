@app.controller "ListsController",
  class ListsController
    @$inject = [ "Restangular" ]

    constructor: ( @Restangular ) ->
      @lists = []
      @busy = true

      @_getLists( {} )

    rescan: ->
      @_getLists( { rescan: true } )

    changeActivation: ( list ) => list.save()

    _getLists: ( params ) ->
            @Restangular.all( 'admin' ).all( 'lists' )
            .getList( params )
            .then( ( lists ) => _( lists ).map( ( list ) => _.assign( list, { cover: @_coverURI( list )} ) ).value() )
            .then( @_updateLists )
            .finally( @_unbusy )

    _coverURI: ( list ) -> "admin/lists/#{ list._id }/cover"

    _updateLists: ( newLists ) => @lists = newLists

    _unbusy: => @busy = false
