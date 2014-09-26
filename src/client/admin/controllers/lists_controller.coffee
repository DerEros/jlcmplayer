@app.controller "ListsController",
  class ListsController
    @$inject = [ "Restangular" ]

    constructor: ( @Restangular ) ->
      @lists = []
      @busy = true

      @Restangular.all( 'admin' ).all( 'lists' ).getList().then( @_updateLists ).finally( @_unbusy )

    rescan: ->
      @Restangular.all( 'admin' ).all( 'lists' ).getList( { rescan: true } ).then( @_updateLists ).finally( @_unbusy )

    _updateLists: ( newLists ) =>
      console.log("Updating list", newLists)
      @lists = newLists

    _unbusy: => @busy = false
