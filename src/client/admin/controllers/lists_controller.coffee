@app.controller "ListsController",
  class ListsController
    @$inject = [ "Restangular" ]

    constructor: ( @Restangular ) ->
      @lists = []
      @busy = true

      @Restangular.all( 'admin' ).all( 'lists' ).getList().then( @_updateLists ).finally( @_unbusy )

    rescan: ->
      @Restangular.all( 'admin' ).all( 'lists' ).getList( { rescan: true } ).then( @_updateLists ).finally( @_unbusy )

    changeActivation: ( list ) => list.save()

    _updateLists: ( newLists ) => @lists = newLists

    _unbusy: => @busy = false
