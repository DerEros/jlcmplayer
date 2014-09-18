@app.controller 'SourcesController',
  class SourcesController
    @$inject = [ '$scope', 'Restangular' ]

    constructor: ( @$scope, Restangular ) ->
      Restangular.all( 'admin' ).all( 'sources' ).getList().then( (list) => @sources = list )

    addSource: ->
      sources = @sources || []
      sources.unshift( new Source( "New", "/", false ) )
