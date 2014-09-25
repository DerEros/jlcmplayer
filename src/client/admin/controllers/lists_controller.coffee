@app.controller "ListsController",
  class ListsController
    @$inject = [ "Restangular" ]

    constructor: ( @Restangular ) ->
      console.log("ListsController")
      @Restangular.all( 'admin' ).all( 'lists' ).getList().then( console.log )

    rescan: ->
      console.log("Rescanning")
      @Restangular.all( 'admin' ).all( 'lists' ).getList( { rescan: true } ).then( console.log )
