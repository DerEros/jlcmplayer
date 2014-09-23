@app.controller "ListsController",
  class ListsController
    @$inject = [ "Restangular" ]

    constructor: (@Restangular) ->
      console.log("ListsController")

    rescan: ->
      console.log("Rescanning")
